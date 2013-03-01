This is an example Perl module showing one method of converting between two different XML dialects, A and X. Here is a sample of dialect A:

	<a>
		<b foo="bar">b-Text</b>
		<c baz="buff">c-Text</c>
	</a>

In XML dialect X, this should equivalently be rendered as such:

	<x>
		<y oof="rab">b-Text</y>
		c-Text
	</x>