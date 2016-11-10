#!/usr/bin/perl
## Splits interleaved FASTQ files into R1 and R2 files
## Pombert Lab, IIT 2016

use strict;
use warnings;


my $usage = "split_iFASTQ.pl *.fastq ## Interleaved FASTQ files";
die "$usage\n" unless @ARGV;

while (my $file = shift@ARGV){
	open IN, "<$file";
	$file =~ s/.fastq$//; $file =~ s/.fq$//;
	open R1, ">$file.R1.fastq";
	open R2, ">$file.R2.fastq";
	my $count = 0;
	while(<IN>){
		chomp $_;
		$count++;
		if ($count <= 4){print R1 "$_\n";}
		elsif ($count != 8){print R2 "$_\n";}
		elsif ($count == 8){print R2 "$_\n"; $count = 0;}
	}
}