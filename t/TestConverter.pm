package t::TestConverter;
use Test::Base -Base;
use XML::Twig;
use 5.010;

# input: xml text and XML::Twig constructor arugments
# return a twig parsed with given arguments, or an error if there was one
sub get_twig($%){
	my ($input, %args) = @_;
	# warn "input is $input";
	my $xml = XML::Twig->new( %args );
	return $xml->parse( $input );
}

package t::TestConverter::Filter;
use Test::Base::Filter -base;
use My::XML::Converter;
use My::XML::Converter::Handlers;
use Data::Dumper;
use XML::Twig;
use Carp;
our $HANDLERS = $My::XML::Converter::Handlers::HANDLERS;

#use these to specify the use of several handlers
#note that ;;ALL;; isn't here, but it will load all available handlers
my $handlerBundles = {
	';;ab;;'		=> [qw(a b)],
	';;abc;;'		=> [qw(a b c)],
};

#parse a given XML string given the list of handlers to use from the Converter handlers
#specify several handlers with a # (pound) in between names
#specifying ;;ALL;; as the argument will simply parse with all of the handlers
sub parse {
	my ($input) = shift @_;
	my $args = Test::Base::Filter::current_arguments();
	if($args eq ';;ALL;;'){
		return _get_twig(undef, $input, $HANDLERS);
	}
	my @handler_names;
	
	#get names of all handlers to be used;
	#expand ones like ;;FONT;; to names listed in $handlerBundles
	for my $name(split '#', $args){
		if($name ~~ $handlerBundles){
			push @handler_names, $_ for @{ $handlerBundles->{$name} };
		}
		else{
			push @handler_names, $name;
		}
	}
	
	my %handlers = map { $_ => $HANDLERS->{$_} } @handler_names;
	return _get_twig(undef, $input, \%handlers);
}

#returns an XML::Twig parse given the input and handlers
sub _get_twig {
    my ( $input, $handlers ) = @_;
	
    my $xml = XML::Twig->new(
		output_encoding => 'UTF-8',
		do_not_chain_handlers => 1, #can be important when things get complicated
		keep_spaces		=> 0,
		TwigHandlers => $handlers
	);
    eval { $xml->parse( $input ) };
    return $@ ? undef: $xml;
}

1;
