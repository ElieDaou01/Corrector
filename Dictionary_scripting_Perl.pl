#!/usr/bin/perl
#THINGS TO STILL DO:
#TAKE ARGUMENT FROM USER,ADD FEATURES, POLISH CODE, OPTIMIZE 
#PLEASE REMEMBER THAT DICTIONARY FILE SHOULD BE PASSED AS ARGUMENT WHEN RUNNING SCRIPT

use strict;
use warnings;
use Text::LevenshteinXS qw(distance);		#library used to calculate levenstein distance (requires C compiler) CPAN link:http://search.cpan.org/~jgoldberg/Text-LevenshteinXS-0.03/LevenshteinXS.pm
use Time::HiRes qw(gettimeofday);		#library used to calculate code run-time (standard perl lib)
my %hasher;
my $start=gettimeofday();
open(READER,"dictionary.txt") || die;	#dictionary file name. Included in send file.
while (my $line = <READER>)		#Inserts dictionary file into hash
{
	chomp $line;
	$hasher{$line}=1;
}
close READER;
open( READER,$ARGV[0] ) || open (READER, input());				#Takes input file from command argument or from user 
print "Please name output file name(Including file extension): \n";	#user inputed output file name as well as extension
my $filen= <STDIN>;
chomp $filen;
open(WRITER,">$filen") || die "Output file writer failed" ;	#output file writer
my $mind;
my $right;
my $capital=0;
my $wrongcap=0;
while(my $line = <READER>)
{
	chomp $line;
	my @words = split(" ",$line);
	my $_ = $words[0];		#Using my $_ returns a warning depending on perl version and might not work with older versions. 
	if(!(/^[A-Z]/))			#Check capitalization at start of new line
	{
		print "\n$_ is not capitalized it should be: " . ucfirst($_) . "\n";
		$line=ucfirst($line);
		$words[0]=ucfirst($words[0]);
		if(!(exists $hasher{$_}))
			{
				$wrongcap=1;
			}
	}
	foreach my $check (@words)
	{
		my @nearest;
		$_ = $check;
		if(/^\W/)		#Check for non word character at the start of the string
		{
			$_= substr $check,1;
			$check = substr $check,1;
		}
		if($check eq 'i')
		{
			print "\n$check is not capitalized it should be: " . ucfirst($check) . "\n";
			$line=~ s/\b$check\b/I/;
			$capital=0;
		}
		else
		{
				$capital=0 if(/^[A-Z]/ and $capital)		;	
				if(!(/^[A-Z]/) and $capital)		#Capitalization check
				{
					print "\n$check is not capitalized it should be: " . ucfirst($check) . "\n";
					$right=ucfirst($check);
					$line=~ s/([.?!]) $check/$1 $right/;
					$capital=0;
				}
				if(/[.?!]$/)			#Checks for characters that require a capital letter afterwards
				{
					chop($check);
					$capital=1;
				}
				else 
				{
					if(/\W$/)
					{
						chop($check);
					}
				}
				$check = lc $check;
				if(!(exists $hasher{$check}))
				{
					@nearest= ([2147483647,""],[2147483647,""],[2147483647,""],[2147483647,""],[2147483647,""]); 	# 2D array containing nearest 5 words and their respective distance
					print "\nWRONG WORD FOUND: $check\n";
					print "Possible replacements: (Best to Worst)\n";
					foreach my $key (keys %hasher)
					{	
						my $temp=distance($check,$key);
						if($temp<$nearest[4][0])
							{
								$nearest[4]=[$temp,$key];					#
								@nearest= sort { $a->[0] <=> $b->[0] } @nearest;		#sort array based on distance
							}
					}
					foreach my $i (0..4)
					{
						print $nearest[$i]->[1] . "\n";
					}
					$right=$nearest[0][1];
					if($wrongcap)			#Checks for capitalization if the word is wrong (for output file)
					{	
						$right=ucfirst($right);
						$check=ucfirst($check);
						$wrongcap=0;
					}
					$wrongcap=1 if($capital);
					$line=~ s/\b$check\b/$right/g;
				}
		}	
	}
	print WRITER "$line\n";
}
close WRITER;
close READER;
my $time = gettimeofday()-$start;
print "\nCode took $time s to run\n";

#user file input sub 
sub input

{
	print "Please enter input file name or filepath: \n";
	my $filen = <STDIN>;
	chomp $filen;
	while (!(-e $filen))
	{
		print "File does not exist please enter again: \n";
		$filen = <STDIN>;
		chomp $filen;
	}
	return $filen;
}
