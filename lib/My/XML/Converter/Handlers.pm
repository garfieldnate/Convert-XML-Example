use strict;
use warnings;
package My::XML::Converter::Handlers;
use feature "state";
use Carp qw(cluck);
# VERSION

our $HANDLERS = {
	a => sub {$_->set_tag('x')},
	b => => sub {$_->set_tag('y')},
	c => \&c,
	
	# might be useful
	# ## '_default_'	=>	\&markAsTodo,
};

sub c {
	my ( $tree, $node ) = @_;
	$node->erase;
}

1;

__END__
I keep a list of all of the tags that are left to process down here