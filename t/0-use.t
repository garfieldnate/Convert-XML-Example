#test that the module is loaded properly

use strict;
use Test::More 0.88;
plan tests => 2;
my $package = 'Convert::XML::Example';

use_ok($package);
new_ok($package);

__END__