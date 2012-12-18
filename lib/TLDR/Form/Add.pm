package TLDR::Form::Add;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

use Data::Validate::URI qw(is_web_uri);

has_field 'url' => (
  required => 1,
  messages => { required => 'URL is required' },
  element_attr => {
    placeholder => 'Please include http(s)://',
  },
);

has_field 'title' => (
  minlength => 5,
  maxlength => 80,
  required => 1,
  messages => { 
    required => 'Title is required',
  },
  element_attr => {
    placeholder => 'Limit to 80 characters please.',
  },
  tags => {
    after_element => qq{\n<span class="help-block">If original title is not descriptive enough please provide your tl;dr; variant.</span>},
  }
);

has_field 'twitter' => (
  type => 'Checkbox',
  checkbox_value => '1',
  option_label => 'Post to Twitter',
  label => '',
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Submit', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

has_block 'add_story' => (
  tag         => 'fieldset',
  label       => 'Add Story',
  render_list => [ 'url', 'title', 'twitter' ],
);


sub build_render_list { ['add_story', 'submit'] }

sub validate_url {
  my ($self, $field) = @_;

  if (! is_web_uri($field->value)) {
    $field->add_error("Please enter correct URL. Make sure to include http(s).");
  }
}

no HTML::FormHandler::Moose;
1;
