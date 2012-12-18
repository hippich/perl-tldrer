package TLDR::Form::Register;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

use Data::Validate::Email qw(is_email);

has user_exists_cb => ( is => 'ro', isa => 'CodeRef' );
has email_exists_cb => ( is => 'ro', isa => 'CodeRef' );

has_field 'username' => (
  required => 1,
  messages => { 
    required => 'Username field is required.',
  },
  element_attr => {
    placeholder => 'Username',
  },
  tags => {
    after_element => qq{\n<span class="help-block">Username will be stored and displayed lowercase.</span>},
  }
);

has_field 'password' => (
  type => 'Password',
  minlength => 5,
  required => 1,
  messages => {
    required => 'Password is required.',
  },
  tags => {
    after_element => qq{\n<span class="help-block">Password is case-sensitive</span>},
  }
);

has_field 'password_repeat' => (
  type => 'Password',
  minlength => 5,
  required => 1,
  messages => {
    required => 'Repeat password field is required.',
  },
);

has_field 'email' => (
  required => 1,
  messages => {
    required => 'Email field is required.',
  },
  element_attr => {
    placeholder => 'johndoe@example.com',
  },
  tags => {
    after_element => qq{\n<span class="help-block">This email address will be used only for communication with you regarding your account at tldrer. No spam guarantee.</span>},
  }
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Register', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

has_block 'register' => (
  tag         => 'fieldset',
  label       => 'Register',
  render_list => [ 'username', 'password', 'password_repeat', 'email' ],
);


sub build_render_list { ['register', 'submit'] }

sub validate_username {
  my ($self, $field) = @_;

  if ($field->value =~ /[^A-Za-z\-_\.0-9]/) {
    $field->add_error("Username should contain only characters from this list: A-Z, a-z, -, _, ., 0-9.");
    return;
  }

  if ($self->user_exists_cb->($field->value)) {
    $field->add_error("This username already taken. Please try different one.");
    return;
  }
}

sub validate_email {
  my ($self, $field) = @_;

  if (! is_email($field->value)) {
    $field->add_error("Please enter correct email address.");
    return;
  }

  if ($self->email_exists_cb->($field->value)) {
    $field->add_error("This email address already in use. You can try to reset password instead.");
    return;
  }
}


after 'validate' => sub {
  my $self = shift;

  if ( $self->field('password')->value ne $self->field('password_repeat')->value ) {
    $self->field('password')->add_error('Two passwords should be the same.');
    $self->field('password_repeat')->add_error('Two passwords should be the same.');
  }
};

no HTML::FormHandler::Moose;
1;
