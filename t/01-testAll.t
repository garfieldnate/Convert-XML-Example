#test structure for a number of different elements
#normally, you'll want to split your tests across several files
	
use t::TestConverter;
use Test::XML;

use Test::More 0.88;
use Data::Dumper;

plan tests => 1 * blocks();

#loop through all blocks, parse the input, and compare with the output
for my $block ( blocks('input') ){
	#compare block; check for undefs first
	if(defined $block->input){
		# print "!!!" . $block->input->sprint;
		is_xml($block->input->sprint, $block->expected, $block->name);
	}
	else{
		fail($block->name);
		note("Parsing XML in input block failed!");
	}
}

__DATA__
use three '=' to name a block
then use three '-' to name input and expected
Note which parsing handlers to use in the input block
=== <a> is converter to <x>
--- input parse=a
<a>A bunch of text!</a>
--- expected
<x>A bunch of text!</x>

=== <b> is converter to <y>
--- input parse=b
<b>A bunch of text!</b>
--- expected
<y>A bunch of text!</y>

=== <c> is erased
you can't erase the root, so we need a dummy
--- input parse=c
<dummy><c>A bunch of text!</c></dummy>
--- expected
<dummy>A bunch of text!</dummy>

=== processing of both a and b work together
you can't erase the root, so we need a dummy
';;ab;;' is the name of a handler bundle, specified in TestConverter.pm
--- input parse=;;ab;;
<dummy>
	<a>A bunch of text!</a>
	<b>A bunch of text!</b>
</dummy>
--- expected
<dummy>
	<x>A bunch of text!</x>
	<y>A bunch of text!</y>
</dummy>

=== processing of a, b and c work together
you can't erase the root, so we need a dummy
';;abc;;' is the name of a handler bundle, specified in TestConverter.pm
--- input parse=;;abc;;
<dummy>
	<a>A bunch of text!</a>
	<b>A bunch of text!</b>
	<c>A bunch of text!</c>
</dummy>
--- expected
<dummy>
	<x>A bunch of text!</x>
	<y>A bunch of text!</y>
	A bunch of text!
</dummy>

=== processing of a and c work together
you can't erase the root, so we need a dummy
'a#c' is a way of tell  TestConverter.pm to use handlers a and c (it splits on '#')
--- input parse=a#c
<dummy>
	<a>A bunch of text!</a>
	<b>A bunch of text!</b>
	<c>A bunch of text!</c>
</dummy>
--- expected
<dummy>
	<x>A bunch of text!</x>
	<b>A bunch of text!</b>
	A bunch of text!
</dummy>

