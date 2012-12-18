package TLDR::Form::AddTLDR;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

has_field 'tldr' => (
  type => 'TextArea',
  label => '',
  maxlength => 400,
  element_attr => {
    placeholder => 'Please add your tl;dr here. Max size is 400 characters.',
  },
  required => 1,
  messages => { 
    required => 'TL;DR; is required',
  },
);

has_field 'twitter' => (
  type => 'Checkbox',
  checkbox_value => '1',
  option_label => 'Post to Twitter',
  label => '',
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Provide your TL;DR; variant.', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

sub build_form_element_class { ['form-vertical'] }

no HTML::FormHandler::Moose;
1;
