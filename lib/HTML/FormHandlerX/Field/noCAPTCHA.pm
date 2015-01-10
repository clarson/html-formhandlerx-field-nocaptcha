package HTML::FormHandlerX::Field::noCAPTCHA;

use Moose;
use Moose::Util::TypeConstraints;
use LWP::UserAgent;
use JSON qw();
use namespace::autoclean;

extends 'HTML::FormHandler::Field';

has '+widget' => ( default => 'noCAPTCHA' );
has '+input_param' => ( default => 'g-recaptcha-response' );
has '+messages' => ( default => sub { {required => 'You must prove your Humanity!'} });
has '+required' => ( default => 1 );

has [qw/site_key secret_key/] => (is=>'rw', isa=>'Str', required => 1,lazy_build => 1);
has 'theme' => (is=>'ro',isa=> enum([qw(dark light)]),default => 'light');
has 'remote_address' => (is=>'ro', isa=>'Str', required => 1, lazy_build => 1);
has 'api_url' => (is=>'ro', isa=>'Str', required => 1, lazy_build => 1);
has 'api_timeout' => (is=>'ro', isa=>'Int', required => 1, lazy_build => 1);
has 'g_captcha_message' => (is=>'ro', isa=>'Str', default=>'You\'ve failed to prove your Humanity!');
has 'g_captcha_failure_message' => (is=>'ro', isa=>'Str', default=>'We\'ve had trouble processing your request, please try again.');
has 'config_key' => (is=>'ro', isa=>'Str', default=> __PACKAGE__);

sub _build_remote_address {
	my ($self) = @_;
	return '' unless ($self->form->ctx);
	return $self->form->ctx->req->address;
}

sub _build_secret_key {
	my ($self) = @_;
	my $config = $self->_g_captcha_config || return;
	return $config->{secret_key};
}

sub _build_site_key {
	my ($self) = @_;
	my $config = $self->_g_captcha_config || return;
	return $config->{site_key};
}

sub _build_api_url {
	my ($self) = @_;
	my $config = $self->_g_captcha_config;
	return $config && $config->{api_url} ? $config->{api_url} : 'https://www.google.com/recaptcha/api/siteverify';
}

sub _build_api_timeout {
	my ($self) = @_;
	my $config = $self->_g_captcha_config;
	return $config && exists $config->{api_timeout} ? $config->{api_timeout} : 10;
}

sub _build_fail_open {
	my ($self) = @_;
	my $config = $self->_g_captcha_config;
	return $config && exists $config->{fail_open} ? $config->{fail_open} : 1;
}

sub _g_captcha_config {
	my ($self) = @_;
	return unless ($self->form && $self->form->ctx && $self->form->ctx->config);
	return $self->form->ctx->config->{$self->config_key};
}

sub validate {
	my ($self) = @_;
	my $answer = $self->form->params->{$self->input_param};

  my $ua = LWP::UserAgent->new;
	$ua->timeout($self->api_timeout);

	my $args = {
		secret   => $self->secret_key,
		response => $self->form->params->{$self->input_param},
	};

	$args->{remoteip} = $self->remote_address if ($self->remote_address);

	my $method = $self->api_url =~ m/^file:/ ? 'get' : 'post';
  my $response = $ua->$method( $self->api_url, $args );

	if (!$response || !$response->is_success || !$response->content) {
		$self->add_error($self->g_captcha_failure_message);
		return;
	}

	my $json = JSON::decode_json($response->content);
	my $success = $json->{success};

	$self->add_error($self->g_captcha_message) unless ($success);
	return;
}

1;

=head1 NAME

HTML::FormHandlerX::Field::noCAPTCHA - Google's noCAPTCHA reCAPTCHA for HTML::FormHandler

=head1 SYNOPSIS

The following is example usage.

In your L<HTML::FormHandler> subclass, "YourApp::HTML::Forms::YourForm":

    has_field 'nocaptcha' => (
        type=>'noCAPTCHA',
        site_key=>'[YOUR SITE KEY]',
        secret_key=>'[YOUR SECRET KEY]',
    );

Example L<Catalyst> controller:

    my $form = YourApp::HTML::Forms::YourForm->new({ctx => $c});
    my $params = $c->request->body_parameters;
    if($form->process($c->req->body_paramseters) {
        ## Do something with the form.
    } else {
        ## Redisplay form and ask to try again.
    }

=head1 FIELD OPTIONS

Support for the following field options, over what is inherited from
L<HTML::FormHandler::Field>

=head2 site_key

Required. The site key you get when you create an account on L<https://www.google.com/recaptcha/>

=head2 secret_key

Required. The secret key you get when you create an account on L<https://www.google.com/recaptcha/>

=head2 theme

Optional. The color theme of the widget. Options are 'light ' or 'dark' (Default: light)

=head2 remote_address

Optional. The user's IP address. Google states this is optional.  If you are using
catalyst and pass the context to the form, noCAPTCHA will use it by default.

=head2 api_url

Optional. URL to the Google API. Defaults to https://www.google.com/recaptcha/api/siteverify

=head2 api_timeout

Optional. Seconds to wait for Google API to respond. Default is 10 seconds.

=head2 g_captcha_message

Optional. Message to display if user answers captcha incorrectly.
Default is "You've failed to prove your Humanity!"

=head2 g_captcha_failure_message

Optional. Message to display if there was an issue with Google's API response.
Default is "We've had trouble processing your request, please try again."

=head2 config_key

Optional. When passing catalyst context to L<HTML::FormHandler>, uses this values
as the key to lookup configurations for this package.
Default is HTML::FormHandlerX::Field::noCAPTCHA

=head1 SEE ALSO

The following modules or resources may be of interest.

L<HTML::FormHandler>

See it in action at L<https://www.httpuptime.com>

=head1 AUTHOR

Chuck Larson C<< <clarson@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2015, Chuck Larson C<< <chuck+github@endcapsoftwware.com> >>

This projects work sponsered by End Cap Software, LLC.
L<http://www.endcapsoftware.com>

Original work by John Napiorkowski C<< <jjnapiork@cpan.org> >>

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
