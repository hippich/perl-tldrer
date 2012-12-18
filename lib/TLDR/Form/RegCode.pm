package TLDR::Form::RegCode;

use HTML::FormHandler::Moose;
extends 'TLDR::Form::Register';

has code => ( is => 'ro', isa => 'Str' );
has code_validate_cb => ( is => 'ro', isa => 'CodeRef' );

has_field 'code' => (
  label => 'Invitation Code',
  required => 1,
);

has_block 'bycode' => (
  tag         => 'fieldset',
  label       => 'Via Invitation Code',
  render_list => [ 'code', 'username', 'email', 'password', 'password_repeat' ],
);

sub build_render_list { ['bycode', 'submit'] }
sub build_form_element_class { ['form-horizontal'] }

sub validate_code {
  my ($self, $field) = @_;

  if (! $self->code_validate_cb->( $field->value )) {
    $field->add_error("Invalid or already used code.");
  }
}

no HTML::FormHandler::Moose;
1;
