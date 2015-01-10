package HTML::FormHandlerX::Widget::Field::noCAPTCHA;

use Moose::Role;
use namespace::autoclean;

# VERSION

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
		my $key = $self->html_filter($self->site_key);
		my $theme = $self->theme;
		my $output=<<EOT;
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<div class="g-recaptcha" data-sitekey="$key" data-theme="$theme"></div>
EOT

    return $output;
}

sub render {
	my ( $self, $result ) = @_;
	$result ||= $self->result;
	die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
	my $output = $self->render_element( $result );
	return $self->wrap_field( $result, $output );
}

1;
