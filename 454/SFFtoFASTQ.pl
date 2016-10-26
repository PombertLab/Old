#!/usr/bin/perl

## Requirements: sffinfo from the gsAssembler suite

use strict;
use warnings;

my $usage = 'USAGE: SFFtoFASTQ.pl *.sff';
die "$usage\n" unless @ARGV;

## Score conversion (Sanger to Illumina, encoded in ASCII:Phred 33+)
my %phredQ = (
'0'=>'!','1'=>'"','2'=>'#','3'=>'$','4'=>'%','5'=>'&',
'6'=>'\'','7'=>'(','8'=>')','9'=>'*','10'=>'+','11'=>',',
'12'=>'-','13'=>'.','14'=>'/','15'=>'0','16'=>'1','17'=>'2',
'18'=>'3','19'=>'4','20'=>'5','21'=>'6','22'=>'7','23'=>'8',
'24'=>'9','25'=>':','26'=>';','27'=>'<','28'=>'=','29'=>'>',
'30'=>'?','31'=>'@','32'=>'A','33'=>'B','34'=>'C','35'=>'D',
'36'=>'E','37'=>'F','38'=>'G','39'=>'H','40'=>'I');

while (my $file = shift@ARGV){
	system "sffinfo $file > $file.txt";
	open IN, "<$file.txt";
	$file =~ s/.sff//;
	open FASTQ, ">$file.fastq";
	my $seqname = undef;   
	my $sequence = undef;	
	while (my $line = <IN>){         
		chomp $line;
		## Extracting the sequence name and writing it down on the first line of the fastq format: @"name of sequence"
		if ($line =~ /^>(\S+)/){
			$seqname = $1;
			print FASTQ "\@$seqname\n";
		}
		## Extracting the sequence and writing it down on the second line of the fastq format + adding the third line "+" spacer 
		elsif ($line =~ /^Bases:\s+(\S+)/){
			$sequence = $1;
			print FASTQ "$sequence\n";   
			print FASTQ "+\n";
		}                                               
		## Extracting quality scores and writing them on the fourth line of the fastq format
		elsif ($line =~ /^Quality Scores:\s+(\d+.*$)/){ 
			my $allQ = $1;
			my $quality = undef;
			if ($allQ =~ m/(\d{1,2})(\s+)/){	## Fhe first quality score
				$quality = $1;
				my $key = $quality;
				print FASTQ "$phredQ{$key}";	## Convert sanger quality scores to illumina Q33 encoding
				while ($allQ =~ s/^\d{1,2}\s+//){	## Iterate through each score
					if ($allQ =~ m/(\d{1,2})/){
						$quality = $1;
						my $key = $quality;
						print FASTQ "$phredQ{$key}";
					}
				}
			}
			print FASTQ "\n";
		}
	}
	system "rm $file.sff.txt";
}