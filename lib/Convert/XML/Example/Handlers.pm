package Convert::XML::Example::Handlers;
# VERSION
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw(get_handlers);

my $handlers = {
	a => sub {$_->set_tag('x')},
	b => => sub {$_->set_tag('y')},
	c => \&c,

	# might be useful
	# ## '_default_'	=>	\&markAsTodo,
};

sub get_handlers {
    return $handlers;
}

sub c {
	my ( $tree, $node ) = @_;
	$node->erase;
}

1;

__END__
I keep a list of all of the tags that are left to process down here