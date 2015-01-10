#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HTML::FormHandler;
use Data::Dumper;

use_ok('HTML::FormHandlerX::Field::noCAPTCHA');

my $form = HTML::FormHandler->new(
	name => 'test_form',
	field_list => [
		'gcaptcha' => {
			type       => 'noCAPTCHA',
			site_key   => 'fake site key',
			secret_key => 'fake secret key',
			api_url    => 'file:t/success_response.json',
			remote_address => '127.0.0.1',
		},
	],
);

ok($form->process({'g-recaptcha-response' => 'happy'}),'all happy path');
my @errors = $form->errors;
cmp_ok(0,'==',scalar @errors);

done_testing();
