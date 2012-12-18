package TLDR::Form::ForgotPassword;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

has login_validate_cb => ( is => 'ro', isa => 'CodeRef' );

has_field 'login' => (
  required => 1,
  messages => { 
    required => 'Login field is required.',
  },
  element_attr => {
    placeholder => 'Username or email you used to sign up',
  },
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Reset Password', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

has_block 'forgot' => (
  tag         => 'fieldset',
  label       => 'Password Reset',
  render_list => [ 'login' ],
);


sub build_render_list { ['forgot', 'submit'] }


sub validate_login {
  my ($self, $field) = @_;

  if (! $self->login_validate_cb->($field->value)) {
    $field->add_error("Unable to find this username or email address in our database. Please double check it.");
  }
}

no HTML::FormHandler::Moose;
1;
