# ABSTRACT: Example XML dialect converter
package My::XML::Converter;
use My::XML::Converter::Handlers;
use strict;
use warnings;

# VERSION

use XML::Twig;

# This package can be used as a standalone program or as a module
__PACKAGE__->new->_run(@ARGV) unless caller;

sub _run {
	my ( $self, $input_file, $output_file) = @_;
	$self->input_fh($input_file);

	if($output_file){
		$self->output_fh($output_file);
	}else{
		$self->output_fh("$input_file.newXML");
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

	#TODO: post-process (add JavaScript)
	my $root = $twig->root;

	# add byte order mark
	print { $self->output_fh } "\x{FEFF}";

	$twig->print( $self->output_fh );
}

1;

__END__

=head1 NAME

	My::XML::Converter- example package for converting between two XML dialects

=head1 SYNOPSIS

	my $converter = My::XML::Converter->new();
	$self->input_fh('C:/path/to/input/XML/file');
	$converter->output_fh('C:/path/to/print/main/to');
	$converter->convert();


=head1 DESCRIPTION

This module is meant to demonstrate one way to convert between different XML dialects. It uses XML::Twig, and contains a Test::Base-based test suite. The test suite has access to the handlers used by the converter, so each one can be tested by itself or in combination with others.

=head1 METHODS

=head2 C<new>

Creates a new My::XML::Converter object

=head2 C<input_fh>

Sets the filehandle of the input XML data to the input argument, which may be a file path or an opened glob.

=head2 C<output_fh>

Sets the filehandle of the output XML data to the input argument, which may be a file path or an opened glob.
