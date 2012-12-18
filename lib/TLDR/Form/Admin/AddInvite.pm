package TLDR::Form::Admin::AddInvite;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

has_field 'code' => (
  type => 'Text',
  label => '',
  required => 1,
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Add new invite code', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

sub build_form_element_class { ['form-vertical'] }

no HTML::FormHandler::Moose;
1;
