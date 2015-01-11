package HTML::FormHandlerX::Widget::Field::noCAPTCHA;

use Moose::Role;
use namespace::autoclean;

# VERSION

sub render_element { return shift->_nocaptcha->html; }

sub render {
	my ( $self, $result ) = @_;
	return '' unless ($result);
	my $output = $self->_nocaptcha->html;
	return $self->wrap_field( $result, $output );
}

1;
