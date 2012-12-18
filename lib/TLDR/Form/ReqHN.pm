package TLDR::Form::ReqHN;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

use Mojo::UserAgent;

has hn_username_validate_cb => (is => 'ro', isa => 'CodeRef');

has_field 'hnuser' => (
  label => 'HN Username: ',
  required => 1,
  css_class => 'span4',
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Request Invite', 
  widget  => 'ButtonTag', 
  element_class => 'btn', 
  css_class => 'span4 request-hn-actions',
);

has_block 'byhn' => (
  tag         => 'fieldset',
  label       => 'Via Hacker News',
  label_class => ['span4'],
  class       => ['row'],
  render_list => [ 'hnuser', 'submit' ],
);

sub build_render_list { ['byhn'] }
sub build_form_element_class { ['form-vertical'] }

sub validate_hnuser {
  my ($self, $field) = @_;

  my $ua = Mojo::UserAgent->new;
  my $tx = $ua->get('http://news.ycombinator.com/user?id='. $field->value);

  if ($tx->res->body =~ /No such user/) {
    $field->add_error("Such username do not exists on HN");
    return;
  }

  my ($karma) = $tx->res->body =~ /karma\:<\/td><td>(\d+)</;

  if ($karma < 100) {
    $field->add_error("We are sorry, but we currently auto-approving only accounts with more than 100 karma at HN. But you are welcome to manualy request invitation code!");
    return;
  }

  if (! $self->hn_username_validate_cb->($field->value)) {
    $field->add_error("This HN username already used.");
    return;
  }
}

no HTML::FormHandler::Moose;
1;
