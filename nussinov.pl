#!/usr/bin/perl -w
use strict;
# use Time::HiRes qw( gettimeofday );               # Time this program

# Nussinov Basic
sub NussinovBasic
{
    # Init method variables
    my $seqRef = pop @_;
    my @seq = split("", $$seqRef);
    my $length = length($$seqRef);
    
    my %WCpairing = ( "A" => "U", "U" => "A", "G" => "C", "C" => "G" );
    
    ($length >= 2 or die "Sequence is only one base long!");

    my(@plot, $i, $j, $k, $temp);

    # Know the size wanted for array; so give the memory manager a hand and allocate it
    $#plot = $length - 1;

    #for(1..$length-1)
    #{
    #    my @row = ((0) x ($_));
    #    #print join(" ",@row)."\n";
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
            #$value += ($WCpairing{substr($$seqRef, $i, 1)} eq substr($$seqRef, $length-(1+$j), 1));
            $value += ($WCpairing{$seq[$i]} eq $seq[$length-(1+$j)]);
            
            if(($plot[$i][$j+1]) && ($temp = $plot[$i][$j+1]) > $value)
            {
                $value = $temp;
            }
            if(($plot[$i+1][$j]) && ($k = $plot[$i+1][$j]) > $value)
            {
                $value = $temp;
            }

            # This slow step should really be avoided, if possible
            if(($k = $length - ($i + 2 + $j)) >= 2 && $plot[$i+2][$j] + $plot[$i][$j+2] > $value)
            #if(defined($plot[$i+2][$j]) && defined($plot[$i][$j+2]) && $plot[$i+2][$j] + $plot[$i][$j+2] > $value)
            {
                for(; $k > 1; --$k)
                #for($k = $length - ($i + 2 + $j); $k > 1; --$k)
                {
                    if(($temp = $plot[$i][$j+$k] + $plot[($length - $j) - $k][$j]) > $value)
                    {
                        $value = $temp;
                    }
                }
            }
            
            $plot[$i][$j] = $value;
        }
    }

    print "Score: $plot[0][0]";
}

# my $start = gettimeofday;

# Allow input from STDIN or Filename in arg
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

NussinovBasic(\$sequence);

# print "Executed in ", gettimeofday - $start, " seconds. \n";