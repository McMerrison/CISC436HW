=begin
Name: Talha Ehtasham
CISC 436 Bioinformatics
Homework 1
=cut

#use strict;
use warnings;
#use List::MoreUtils qw(first_index);

my @chars = ("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V");
my $length = 50;
my @matrix;


=begin
Generate a random string of amino acids using array of given letters
Use global length variable to determine how long seuqnce will begin
=cut
sub rand_seq
{
	my $seq;
	for ($a = 0; $a < $length; $a++) {
		$seq .= $chars[rand @chars];
	}
	$seq;
}

=begin
Read pam1 text file
For each row, parse through whitespaces
Add each number to matrix
Use this matrix to compare amino acid replacement probaility
=cut
sub readpam
{
	my $i = 0;
	my $j = 0;
	my $filename = 'pam1.txt';
	open(my $pam, $filename) or die "ERROR";
	
	while (my $row = <$pam>) {
		my @tokens = split /\s{1,}/, $row;
		foreach my $token(@tokens) {
			
			$matrix[$i][$j] = $token;
			#print "$token ";
			$j++;
		}
		#print "$j";
		$i++;
		$j = 0;
		
	}
}

=begin
Take sequence generated in rand_seq
For each amino acid:
1. Check against array of characters, the index will match matrix column (use first_index)
2. Call random function to determine which amino acid will replace it
2. Use this against pam1 matrix
3. Replace char in string to new amino acid (no change if it's the same)
=cut
sub mutate_seq
{
	my $str = $_[0];
	foreach $letter (split //, $str) {
		$x = 0;
		foreach (@chars) {
			if ($_ eq $letter) {
				$index = $x;
				$in = &weightarray($index);
				my $replace = $chars[$in];
				substr($str,$x,1) =  $replace;
			}
		}
		$x++;
	}
	return $str;
}

=begin
Create an array based off the column of replacement probabilities at given index
Sort this array and reverse so it goes from largest to smallest probability
Generate random # from 0 to 10,000
Iterate through weighted array and determine which "section" random number falls into
Return original index of replaced amino acid. Note, there might be multiple 1s or 0s in a given 
row, and it's possible the incorrect amino acid is chosen. However, since they all have a chance of 0.01%,
accurate probability is preserved.
=cut
sub weightarray
{
	for ($t = 0; $t < 20; $t++)
	{
		$weightarrunsort[$t] = $matrix[$t][$_[0]];
	}
	@weightarr = sort { $a <=> $b }  @weightarrunsort;
	@weightarr = reverse @weightarr;
	#for(my $i = 0; $i < 20; $i++) {
		#print "$weightarr[$i] ";
	#}
	my $evolve = &randcalc;
	$lim = 0;
	$k = 0;
	while ($lim < 10000) {
		$lim += $weightarr[$k];
		if ($evolve < $lim) {
			$f = &findindex(\@weightarrunsort, $weightarr[$k]);
			return $f;
		}
		$k++;
	}
}

=begin
When the array was sorted, the original indexes were lost. In order to return the correct index,
we have to find the calculated number from the range found in weightarray.
=cut
sub findindex
{
	my @array = @{$_[0]};
	for(my $i = 0; $i < 20; $i++) {
		#print "$array[$i] ";
	}
	#print "\n";
	my $number = $_[1];
	#print "Searching for $number \n";
	my $p = 0;
	foreach my $elem(@array) {
		if ($elem == $number) {
			#print "Returning index $p \n";
			return $p;
		}
		else {
			$p++;
		}			
	}
}

=begin
Sort the weighted array using bubble sort 
It isn't the ideal algorithm but we will always have only 20 elements
So in this case it is acceptable
This allows us to more easily use weighted selection from the PAM column
Based on online implementation
=cut
sub bubble {
    my $array = @_;
    my $unsorted = 1;
    my $index;
    my $len = 18;
    while ($unsorted) {
        $unsorted = 0;
        foreach $index (0 .. $len) {
            if (@$array[$index] > @$array[$index + 1]) {
                my $temp = @$array[$index + 1];
                @$array[$index + 1] = @$array[$index];
                @$array[$index] = $temp;
                $unsorted = 1;
            }
        }
    }
}

=begin
Generate a random number
Use to calculate if amino acid will be replaced
=cut
sub randcalc
{
	my $random = rand()*10000;
	$random;
}

=begin 
Compare two sequences, determine how many replacements occured
=cut
sub compare
{
	$seq1 = $_[0];
	$seq2 = $_[1];
	$diffcount;
	for (my $ind = 0; $ind < 19; $ind++) {
		my $one = substr($seq1, $ind, 1);
		my $two = substr($seq2, $ind, 1);
		if ($one ne $two) {
			$diffcount++;
		}
	}
	print "$diffcount differences found \n";
	
}

=begin
Print, row by row, the matrix generated by the readpam subroutine
=cut
sub printmatrix
{
	for($row = 0; $row < 20; $row++) {
		for($col = 0; $col < 20; $col++) {
			print "$matrix[$row][$col] ";
		}
		print "\n";
	}
}


=begin
Main program
=cut
$ancestor = &rand_seq;
&readpam;
print "$ancestor \n";
$sequence = &mutate_seq($ancestor);
for ($iter = 0; $iter < 50; $iter++) {
	$sequence = &mutate_seq($sequence);
}
print "$sequence\n";
&compare($ancestor, $sequence);



