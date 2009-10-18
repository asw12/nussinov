#!/usr/bin/perl -w
use strict;
# use Time::HiRes qw( gettimeofday );               # Time this program

sub GetScore
{
    my($plotRef, $i, $j) = @_;
    return $plotRef->[$i]->[$j];
}

sub CalcScore
{
    my($plotRef, $i, $j) = @_;
    return 1;
}

# Nussinov Basic
sub NussinovBasic
{
    # Init method variables
    my $seqRef = pop @_;
    my $length = length($$seqRef);
    
    my %WCpairing = ( "A" => "U", "U" => "A", "G" => "C", "C" => "G" );
    
    ($length >= 2 or die "Sequence is only one base long!");

    my(@plot, $i, $j, $k);

    # Know the size wanted for array; so give the memory manager a hand and allocate it
    $#plot = $length - 1;

    #for(1..$length-1)
    #{
    #    my @row = ((0) x ($_));
    #    $plot[$_] = \@row;
    #}
    
    # Numbering starts at 0,0 in the top right corner, down to $length-2 at the left and bottom ends of the plot
    #  This way avoids negative indexes, because the code doesn't explicitly error check for the end of the arrays
    for($i = $length-2; $i >= 0; --$i)
    {
        # $length-(2+$i) is the width of the current row
        for($j = $length-(2+$i); $j >= 0; --$j)
        {
            # Store the diagonal step (delta(i,j) + score(i-1,j-1)) in value / converts undefined to 0 in one step (save a scrap of memory)
            my $value = $plot[$i+1][$j+1];
            $value += ($WCpairing{substr($$seqRef, $i, 1)} eq substr($$seqRef, $length-(1+$j), 1));
            
            if(($plot[$i][$j+1]) && $plot[$i][$j+1] > $value)
            {
                $value = $plot[$i][$j+1];
            }
            if(($plot[$i+1][$j]) && $plot[$i+1][$j] > $value)
            {
                $value = $plot[$i+1][$j];
            }

            # This slow step should really be avoided, if possible
            #if($plot[-100])
            
            $plot[$i][$j] = $value;
            
            #print "$i, $j, Value : $value \n";
        }
    }

    print "Score: $plot[0][0]";
}

# my $start = gettimeofday;

# Allow input from STDIN or File
my $sequence;
#  File
if($ARGV[0])
{
    open(FILE, $ARGV[0]) or die $!." \"$ARGV[0]\"";
    $sequence = <FILE>;
}
#  STDIN
else
{
    $sequence = <>;
}

# Trim the string and make it caps
$sequence =~ s/\s+$//;
$sequence = uc($sequence);

# Verify the RNA string
if( $sequence =~ /([^AUGC])/ )
{
    die "Sequence contains non-ribonucleotide at index ".length($`)."! '$1' \n\t";
}

if(length($sequence) < 1000)
{
    NussinovBasic(\$sequence);
}
else
{
    NussinovBasic(\$sequence);
}

# print "Executed in ", gettimeofday - $start, " seconds. \n";