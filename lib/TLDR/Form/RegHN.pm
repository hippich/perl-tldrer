package TLDR::Form::RegHN;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Register';

has code => ( is => 'ro', isa => 'Str' );

has_field 'hnuser' => (
  label => 'HN Username: ',
  required => 1,
);

has_field 'register' => (
  type => 'Hidden',
  default => 'hn', 
);

has_block 'byhn' => (
  tag         => 'fieldset',
  label       => 'Via Hacker News',
  render_list => [ 'hnuser', 'username', 'email', 'password', 'password_repeat' ],
);

sub build_render_list { ['byhn', 'register', 'submit'] }
sub build_form_element_class { ['form-horizontal'] }

sub validate_hnuser {
  my ($self, $field) = @_;

  my $ua = Mojo::UserAgent->new;
  my $tx = $ua->get('http://news.ycombinator.com/user?id='. $field->value);
  my $code = $self->code;

  if ($tx->res->body !~ /$code/) {
    $field->add_error("Can't find code on your profile page.");
    return;
  }
}

no HTML::FormHandler::Moose;
1;
