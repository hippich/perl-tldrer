package TLDR::Model;

use Moose;
use Carp;
use Redis::Client;
use MLDBM qw(Redis::Client::Hash JSON);
use Variable::Magic qw(wizard cast);
use Scalar::Util qw/weaken/;
use Clone qw/clone/;
use Data::Compare;

use Data::Dumper;

use feature 'state';

has client => ( isa => 'Redis::Client', is => 'rw' );
has [qw/ stories story_id_by_url users emails invites /] => ( is => 'rw' );

#############################################################################
# Variable wizard to autosave tied value back to Redis whenever 
# variable freed.

my $wiz = wizard(
  data => sub {
    return $_[1];
  },
  free => sub {
    return if Compare($_[1][2], $_[0]);
    $_[1][0]->{ $_[1][1] } = $_[0];
  },
);


sub BUILD {
  my ($self, $params) = @_;

  $self->client( 
    Redis::Client->new( host => $params->{host} || 'localhost', port => $params->{port} || 6379 ) 
  );

  # Ties to various data stored
  my ($stories, $story_id_by_url, $users, $emails, $invites);
  tie %$stories, 'MLDBM', key => 'stories', client => $self->client;
  tie %$story_id_by_url, 'MLDBM', key => 'story_id_by_url', client => $self->client;
  tie %$users, 'MLDBM', key => 'users', client => $self->client;
  tie %$emails, 'MLDBM', key => 'emails', client => $self->client;
  tie %$invites, 'MLDBM', key => 'invites', client => $self->client;

  $self->stories( $stories );
  $self->story_id_by_url( $story_id_by_url );
  $self->users( $users );
  $self->emails( $emails );
  $self->invites( $invites );

}

sub url_exists {
  my ($self, $url) = @_;
  return unless $url;
  return $self->story_id_by_url->{ $url };
}

sub add_story {
  my ($self, $story) = @_;

  my $story_id = $self->url_exists($story->{url});

  return $story_id unless !$story_id;

  # get new unique id for this story based on url
  $story_id = $self->get_story_id( $story->{url} );

  # Assign some default values to the story
  $story->{id} = $story_id;
  $story->{votes} = 1;

  # Add vote to author
  my $user = $self->get_user($story->{username});
  $user->{votes}->{$story_id} = 1;

  # Add title as TLDR
  $story->{top_tldr} = -1;

  # Save story to stories hash
  $self->stories->{$story_id} = $story;

  # Add story id to top and new lists
  $self->client->zadd( top => time(), $story_id );
  $self->client->zadd( new => time(), $story_id );

  return $story_id;
}


sub get_story_id {
  my ($self, $url) = @_;

  my $story_id = $self->story_id_by_url->{$url};

  if (! $story_id) {
    $story_id = $self->client->rpush( story_url_by_id => $url );
    $self->story_id_by_url->{$url} = $story_id;
  }

  return $story_id;
}


sub get_top {
  return shift->client->zrevrangebyscore( top => '+inf', '-inf', 'LIMIT', shift || 0, shift || 30 );
}

sub get_new {
  return shift->client->zrevrangebyscore( new => '+inf', '-inf', 'LIMIT', shift || 0, shift || 30 );
}

sub story {
  state $stories_cache;
  my ($self, $story_id) = @_;

  if ($stories_cache->{$story_id}) {
    return $stories_cache->{$story_id};
  }

  my $story = $self->stories->{ $story_id } or return;

  cast %$story, $wiz, [$self->stories(), $story_id, clone($story)];
  $stories_cache->{$story_id} = $story;
  weaken($stories_cache->{$story_id});

  return $story;
}

sub story_by_url {
  my ($self, $url) = @_;

  return unless $self->url_exists( $url );

  return $self->story( $self->get_story_id($url) );
}


sub story_tldr_recalc {
  my ($self, $story_id, $tldr_id, $vote) = @_;
  my $story = $self->story($story_id);
  my $tldr = $story->{tldr}->[$tldr_id];

  # Add vote
  $tldr->{votes} += $vote;

  # Recalculate top tldr 
  if ($vote > 0) {
    if ($story->{top_tldr} == -1) {
      $story->{top_tldr} = $tldr_id;
    }
    else {
      my $top_tldr = $story->{tldr}->[ $story->{top_tldr} ];
      if ($tldr->{votes} > $top_tldr->{votes}) {
        $story->{top_tldr} = $tldr_id;
      }
    }
  }
  elsif ($story->{top_tldr} == $tldr_id) {
    # Have to scan all tldrs to find next best one =(
    my $best_tldr = $tldr_id;
    for my $i (0 .. $#{$story->{tldr}}) {
      if ($story->{tldr}->[$i]->{votes} > $story->{tldr}->[$best_tldr]->{votes}) {
        $best_tldr = $i;
      }
    }

    $story->{top_tldr} = $best_tldr;
  }

  return $story;
}


### User-related
#
sub add_user {
  my ($self, $user) = @_;
  
  $self->users->{ $user->{username} } = $user;
  $self->emails->{ $user->{email} } = $user->{username};
}

sub get_user {
  state $users_cache;

  my ($self, $user_id) = @_;

  return unless $user_id;

  if ($users_cache->{$user_id}) {
    return $users_cache->{$user_id};
  }

  my $user = $self->users->{ $user_id } or return;

  cast %$user, $wiz, [$self->users(), $user_id, clone($user)];
  $users_cache->{$user_id} = $user;
  weaken($users_cache->{$user_id});

  return $user;
}

sub get_user_by_email {
  my ($self, $email) = @_;

  return unless $email;

  my $username = $self->emails->{ $email } or return;
  return $self->get_user($username);
}

sub hn_username_exists {
  my ($self, $username) = @_;
  return unless $username;
  return $self->client->hget('hnusernames', $username);
}

sub add_hn_username {
  return shift->client->hset('hnusernames', shift, shift);
}

1;
