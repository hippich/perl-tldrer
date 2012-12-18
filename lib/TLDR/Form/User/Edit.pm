package TLDR::Form::User::Edit;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Base';

use Data::Validate::Email qw(is_email);

has email_exists_cb => ( is => 'ro', isa => 'CodeRef' );
has pass_validate_cb => ( is => 'ro', isa => 'CodeRef' );

has_field 'old_password' => (
  type => 'Password',
  required => 1,
  messages => {
    required => 'Old password is required.',
  },
  tags => {
    after_element => qq{\n<span class="help-block">Passwords are case-sensitive</span>},
  }
);

has_field 'password' => (
  type => 'Password',
);

has_field 'password_repeat' => (
  type => 'Password',
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

has_field 'aboutyou' => (
  type => 'TextArea',
  label => 'About you',
);

has_field 'submit' => ( 
  type    => 'Submit', 
  value   => 'Save', 
  widget  => 'ButtonTag', 
  element_class => 'btn' 
);

has_block 'edit' => (
  tag         => 'fieldset',
  label       => 'Edit Profile',
  render_list => [ 'old_password', 'password', 'password_repeat', 'email', 'aboutyou' ],
);


sub build_render_list { ['edit', 'submit'] }

sub validate_old_password {
  my ($self, $field) = @_;

  if (! $self->pass_validate_cb->($field->value)) {
    $field->add_error("Old password is incorrect.");
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

  if ( $self->field('password')->value() && $self->field('password_repeat')->value() ) {
    if ( $self->field('password')->value ne $self->field('password_repeat')->value ) {
      $self->field('password')->add_error('Two passwords should be the same.');
      $self->field('password_repeat')->add_error('Two passwords should be the same.');
    }
  }
};

no HTML::FormHandler::Moose;
1;
