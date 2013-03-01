# ABSTRACT: LDS XML to ETAX converter
package My::XML::Converter;
use My::XML::Converter::Handlers;
use strict;
use warnings;

# VERSION

use XML::Twig;

# This package can be used as a standalone program or as a module
__PACKAGE__->new->_run(@ARGV) unless caller;

sub _run {
	my ( $self, $inputFile, $outputFile, $studyNotesFile, $backMatterFile ) = @_;
	$self->input_fh($inputFile);
	
	if($outputFile){
		$self->output_fh($outputFile);
	}else{
		$self->output_fh("$inputFile.newXML");
	}
	
	$self->convert();
}

sub new {
	my ( $class, $config ) = @_;
	my $self = bless {}, $class;
	$self->_init();
	$self;
}

sub _init {
	my ( $self, $config ) = @_;
	
	$self->{input_fh}  = \*STDIN;
	$self->{output_fh} = \*STDOUT;
}

# set or get the output filehandle; argument may be a file handle or string filename
# optional argument: name to give filehandle (use for footnotes/backmatter)
sub output_fh {
	my ( $self, $fh, $name ) = @_;
	if ($fh) {
		if ( ref($fh) eq 'GLOB' ) {
			$self->{output_fh} = $fh;
		}
		else {
			open my $fh2, '>utf8', $fh or die "Couldn't open $fh";
			$self->{output_fh} = $fh2;
		}
	}
	$self->{output_fh};
}

# set or get the input filehandle; argument may be a file handle or string filename
sub input_fh {
	my ( $self, $fh ) = @_;
	if ($fh) {
		if ( ref($fh) eq 'GLOB' ) {
			$self->{input_fh} = $fh;
		}
		else {
			open my $fh2, '<', $fh or die "Couldn't open $fh";
			$self->{input_fh} = $fh2;
		}
	}
	$self->{input_fh};
}

# Main subroutine; once all of the input/output stuff is set, call this and it will
# do all of the work.
# Optional argument: input (filename or GLOB)
sub convert {
	my ($self, $input) = @_;
	$self->input_fh($input)
		if defined $input;

	# build a twig out of the input document
	my $twig = new XML::Twig(
		pretty_print    => 'nice', #this seems to affect other created twigs, too
		output_encoding => 'UTF-8',
		do_not_chain_handlers => 1, #can be important when things get complicated
		keep_spaces		=> 0,
		TwigHandlers    => $My::XML::Converter::Handlers::HANDLERS,
	);
	
	# use handlers to process individual tags, then grab the result
	$twig->parse( $self->input_fh );
	my $root = $twig->root;

	# add byte order mark
	print { $self->output_fh } "\x{FEFF}";

	$twig->print( $self->output_fh );
}

1;
