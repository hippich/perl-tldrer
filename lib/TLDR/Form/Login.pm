package TLDR::Form::Login;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

has user_validate_cb => ( is => 'ro', isa => 'CodeRef' );

has_field 'username' => (
  required => 1,
  messages => { 
    required => 'Username field is required.',
  },
  element_attr => {
    placeholder => 'Username',
  },
);

has_field 'password' => (
  type => 'Password',
  required => 1,
  messages => {
    required => 'Password is required.',
  },
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Login', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

has_block 'login' => (
  tag         => 'fieldset',
  label       => 'Login',
  render_list => [ 'username', 'password' ],
);


sub build_render_list { ['login', 'submit'] }


after 'validate' => sub {
  my $self = shift;

  return unless $self->validated;

  if ( $self->field('username') ne '' && $self->field('password') ne '' ) {
    if (! $self->user_validate_cb->( $self->field('username')->value, $self->field('password')->value )) {
      $self->field('username')->add_error('Username and/or password is incorrect. Try again or try to reset password.');
    }
  }
};

no HTML::FormHandler::Moose;
1;
