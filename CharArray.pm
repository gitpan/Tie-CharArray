use strict;
require 5.005; # needs 4-arg substr
$Tie::CharArray::VERSION = '0.02';

# POD documentation after __END__ below

package Tie::CharArray;
use base 'Tie::Array';
use Carp;

sub TIEARRAY {
    my $class = shift;
    carp "Too many parameters for tie to $class" if @_ > 1 and $^W;
    my $self = @_ ? \\$_[0] : \\(my $foo = ""); 
    bless $self, $class;
}

sub FETCH     { return substr $${$_[0]}, $_[1], 1; }
sub FETCHSIZE { return length $${$_[0]}; }

sub STORE     { substr $${$_[0]}, $_[1], 1, $_[2]; }
sub STORESIZE { substr $${$_[0]}, $_[1], length($${$_[0]})-$_[1], ""; }
sub EXISTS    { return $_[1] < length $${$_[0]}; }

sub CLEAR     { $${$_[0]} = ""; }
sub PUSH      { $${$_[0]} .= join "" => @_[1..$#_]; }
sub POP       { return substr $${$_[0]}, -1, 1, ""; }
sub SHIFT     { return substr $${$_[0]}, 0, 1, ""; }
sub UNSHIFT   { $${$_[0]} = join "" => @_[1..$#_], $${$_[0]}; }
sub SPLICE    { return split // => substr $${$_[0]}, $_[1], $_[2], join "" => @_[3..$#_]; }


package Tie::CharArray::Ord;
use base 'Tie::CharArray';

sub FETCH     { return ord substr $${$_[0]}, $_[1], 1; }
sub STORE     { substr $${$_[0]}, $_[1], 1, chr $_[2]; }
sub PUSH      { $${$_[0]} .= pack 'C*' => @_[1..$#_]; }
sub POP       { return ord substr $${$_[0]}, -1, 1, ""; }
sub SHIFT     { return ord substr $${$_[0]}, 0, 1, ""; }
sub UNSHIFT   { $${$_[0]} = (pack 'C*' => @_[1..$#_]) . $${$_[0]}; }
sub SPLICE    { return unpack 'C*' => substr $${$_[0]}, $_[1], $_[2], pack 'C*' => @_[3..$#_]; }


"That's all, folks!"
__END__

=head1 NAME

Tie::CharArray - Access Perl scalars as arrays of characters

=head1 SYNOPSIS

    use Tie::CharArray;
    my $foobar = 'a string';

    tie my @foo, 'Tie::CharArray', $foobar;
    $foo[0] = 'A';    # $foobar = 'A string'
    push @foo, '!';   # $foobar = 'A string!'
    print "@foo\n";   # prints: A   s t r i n g !

    tie my @bar, 'Tie::CharArray::Ord', $foobar; 
    $bar[0]--;        # $foobar = '@ string!'
    pop @bar;         # $foobar = '@ string'
    print "@bar\n";   # prints: 64 32 115 116 114 105 110 103

=head1 DESCRIPTION

In low-level programming languages such as C, and to some extent
Java, strings are not primitive data types but arrays of characters,
which in turn are treated as integers.  This closely matches the
internal representation of strings in the memory.

Perl, on the other hand, abstracts such internal details away behind
the concept of scalars, which can be treated as either strings or
numbers, and appear as primitive types to the programmer.  This often
better matches the way people think about the data, which facilitates
programming by making common high-level manipulation tasks trivial.

Sometimes, though, the low-level view is better suited for the task at
hand.  Perl does offer functions such as ord()/chr(), pack()/unpack()
and substr() that can be used to solve such tasks with reasonable
efficiency.  For someone used to the direct access to the internal
representation offered by other languages, however, these functions
may feel awkward.  While this is often only a symptom of thinking in
un-Perlish terms, sometimes being able to manipulate strings as
character arrays really does simplify the code, making the intent more
obvious by eliminating syntactic clutter.

This module provides a way to manipulate Perl strings through tied
arrays.  The operations are implemented in terms of the aforementioned
string manipulation functions, but the programmer normally need not be
aware of this.  As Perl has no primitive character type, two
alternative representations are provided:

=head2 Strings as arrays of single-character strings

The first way is to represent characters as strings of length 1.  In
most cases this is the most convenient representation, as such
"characters" can be printed without explicit transformations and
written as ordinary Perl string literals.

This representation is provided by the main class Tie::CharArray.  As
the class maps most array operations directly to calls to substr(),
several features of that function apply.  (Below, C<@foo> is an array
tied to Tie::CharArray and C<$n> is a positive integer.)

=over 4

=item *

C<$foo[@foo]> is an empty string, C<$foo[@foo+$n]> is C<undef>.

=item *

Assigning to C<$foo[@foo+$n]> is a fatal error.  So is splice() beyond
the end of the array.

=item *

If you assign an empty string (or C<undef>) to an element, any later
elements are shifted down.

=item *

If you assign a string longer than one character to an element, any
later elements are shifted up.

=back

In general, if you only put one-character strings into the array, and
don't go beyond its end, there should be no problems.

=head2 Strings as arrays of small integers

While the representation described above is usually the most
convenient one, it still does not allow direct arithmetic manipulation
of the character code values.  For tasks where this is needed, an
alternative representation is provided by the subclass
Tie::CharArray::Ord.  Note that it is perfectly possible to manipulate
a single string through both interfaces at the same time.  As the
array operations are still based on substr(), the first two of the
above caveats apply here as well.

=head1 BUGS

Exposing the peculiarities of substr() to the user might be considered
a bug.  In any case, it is a feature which one should probably not
rely on, as it might change in future revisions.

=head1 AUTHORS

Copyright 2000, Ilmari Karonen.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Address bug reports and comments to: perl@itz.pp.sci.fi

=head1 SEE ALSO

Tie::Array, substr()

=cut
