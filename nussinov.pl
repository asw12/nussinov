#!/usr/bin/perl -w
use strict;
use Time::HiRes qw( gettimeofday );               # Time this program
my $startTime = gettimeofday;

# Takes in both a one line argument or reads directly from STDIN or a -f followed by a file to read from

# Straight forward algorithm
sub NussinovBasic
{
    # Init method variables
    my $seqRef = pop @_;
    #my $length = length($$seqRef);
    my @seq = split("", $$seqRef);
    my $length = scalar(@seq);

    my %WCpairing = ( "A" => "U", "U" => "A", "G" => "C", "C" => "G" );

    ($length >= 2 or die "Sequence is only one base long!");

    my(@plot, $i, $j, $k, $temp);

    # Know the size wanted for array; so give the memory manager a hand and allocate it
    $#plot = $length - 1;

    # Numbering starts at 0,0 in the top right corner, down to $length-2 at the left and bottom ends of the plot
    #  This way avoids negative indexes, because the code doesn't explicitly error check for the end of the arrays
    for($i = $length-2; $i >= 0; --$i)
    {
        # $length-(1+$i) is the width of the current row
        # $#{$plot[$i]} = $length-(1+$i); # uncomment to set row length (didn't seem to be worth is)

        for($j = $length-(2+$i); $j >= 0; --$j)
        {
            # Store the diagonal step (delta(i,j) + score(i-1,j-1)) in value / converts undefined to 0 in one step (save a scrap of memory)
            my $value = $plot[$i+1][$j+1];
            $value += $WCpairing{$seq[$i]} eq $seq[$length-(1+$j)];

            if($plot[$i][$j+1] || $plot[$i+1][$j])
            {
                if(($temp = $plot[$i][$j+1]) > $value)
                {
                    $value = $temp;
                }

                # This slow (k) step should really be avoided, if possible
                #  So it is buried past the conditions that allow the other steps
                #  $plot[$i][$j+2] both checks if that cell is defined AND nonzero
                if($plot[$i+1][$j] == $plot[$i][$j+1])
                {
                    for($k = $length - ($i + 2 + $j); $k > 1; --$k)
                    {
                        if(($temp = $value - ($plot[$i][$j+$k] + $plot[($length - $j) - $k][$j])) < 0)
                        {
                            $value++;
                            last; # It should be proveable that the score will only increase by 1 at most
                        }
                        elsif($temp > 1)
                        {
                            # Exploit the property that each increase in k only changes the score of this step by at most +2
                            $k -= ($temp) >> 1;
                        }
                    }
                }
                elsif(($temp = $plot[$i+1][$j]) > $value)
                {
                    $value = $temp;
                }

            }

            $plot[$i][$j] = $value;
        }
    }

    # Uncomment to print plot out for kicks
    #my $printBufferSpace = 1;
    #print "", (" " x $printBufferSpace), join((" " x $printBufferSpace),@seq), "\n";
    #for($i = 0; $i <= $length-1; ++$i)
    #{
    #    print "", (" " x $printBufferSpace), (" " x (($printBufferSpace+1)*($i))), "0";
    #    for($j = $length-(2+$i); $j >= 0; --$j)
    #    {
    #        print (" " x (($printBufferSpace+1)-length($plot[$i][$j])));
    #        print $plot[$i][$j];
    #    }
    #    print "", (" " x $printBufferSpace), "$seq[$i]\n";
    #}

    print STDERR "Score: $plot[0][0] ";
}

# Allow input from STDIN or Filename (with -f) or Sequence in @ARGV
my $sequence;
#  File
if($ARGV[0])
{
    if($ARGV[0] eq "-f")
    {
        open(FILE, $ARGV[1]) or die $!." \"$ARGV[1]\"";
        $sequence = <FILE>;
    }
    else
    {
        $sequence = $ARGV[0];
    }
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

print STDERR " Executed in ", gettimeofday - $startTime, "\n";