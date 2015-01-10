# html-formhandlerx-field-nocaptcha
Google's noCAPTCHA reCAPTCHA for HTML::FormHandler

### In your HTML::FormHandler subclass, "YourApp::HTML::Forms::YourForm":

```perl
	has_field 'nocaptcha' => (
		type=>'noCAPTCHA',
		site_key=>'[YOUR SITE KEY]',
		secret_key=>'[YOUR SECRET KEY]',
	);
```

### Example L<Catalyst> controller:

```perl
	my $form = YourApp::HTML::Forms::YourForm->new({ctx => $c});
	my $params = $c->request->body_parameters;
	if($form->process($c->req->body_paramseters) {
		## Do something with the form.
	} else {
		## Redisplay form and ask to try again.
	}
```

## COPYRIGHT & LICENSE

Copyright 2015, Chuck Larson <chuck+github@endcapsoftwware.com>

This projects work sponsered by End Cap Software, LLC.
http://www.endcapsoftware.com

Original work by John Napiorkowsk <jjnapiork@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.
