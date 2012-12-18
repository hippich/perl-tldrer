package TLDR::Form::RequestInvite;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

has_field 'aboutmyself' => (
  type => 'TextArea',
  label => 'Tell about yourself:',
  minlength => 10,
  required => 1,
  element_attr => {
    placeholder => 'Please describe why you want to join and include links to your social profiles if any. We are looking for people who have track of records contributing to social sites.',
  },
  css_class => 'span4',
);

has_field 'email' => (
  label => 'Email: ',
  required => 1,
  messages => {
    required => 'Email field is required.',
  },
  element_attr => {
    placeholder => 'johndoe@example.com',
  },
  css_class => 'span2',
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Request Invite', 
  widget  => 'ButtonTag', 
  element_class => 'btn', 
  css_class => 'span2 request-invite-actions',
);

has_block 'byinvite' => (
  tag         => 'fieldset',
  label       => 'By Invite',
  label_class => ['span4'],
  class       => ['row'],
  render_list => [ 'aboutmyself', 'email', 'submit' ],
);

sub build_render_list { ['byinvite'] }
sub build_form_element_class { ['form-vertical'] }

no HTML::FormHandler::Moose;
1;
