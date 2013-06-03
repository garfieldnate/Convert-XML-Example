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
use Test::Base::Filter -Base;
use Convert::XML::Example;
use Convert::XML::Example::Handlers;
use Data::Dumper;
use XML::Twig;
use Carp;
my $handlers = get_handlers();

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
	my ($input) = (@_);
	# warn $input;
	my $args = $self->current_arguments();
	if($args eq ';;ALL;;'){
		return $self->_get_twig($input, $handlers);
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

	my %handlers = map { $_ => $handlers->{$_} } @handler_names;
	use Data::Dumper;
	return $self->_get_twig($input, \%handlers);
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
