#!/usr/bin/perl

## SSRG: Synthetic Short Read Generator
## Generates synthetic short reads in Fastq (Q33) format from multifasta files
## Pombert JF, Illinois Institute of Technology (2015)

use strict;
use warnings;

my $usage = 'USAGE = perl SSRG.pl desired_read_size *.fasta'."\n";
die $usage unless(scalar@ARGV>=2);

## Sliding windows parameters
my $winsize = shift@ARGV;	## replace with the desired width of the sliding windows.
my $slide = 1;				## replace with the desired span of the slide, e.g. slide every nucleotide or every 10, 100 and so forth.
## End of sliding windows parameters

while (my $fasta = shift @ARGV) {

	open IN, "<$fasta" or die "cannot open $fasta";
	$fasta =~ s/\.fasta$//; $fasta =~ s/\.fsa$//; $fasta =~ s/\.fa$//; ## Removing file extensions
	open OUT, ">$fasta.fastq";

	my @contigs = (); ## Initializing list of contigs per fasta file
	my %contigs = (); ## Initializing hash of contigs per fasta file key = contig name; value = sequence
	my $name = undef; ## Contig name to be memorized
	my $count = 0; ## Read number counter to be auto-incremented
	
	while (my $line = <IN>){
		chomp $line;
		if ($line =~ /^>(.*)$/){
			$name = $1;
			push(@contigs, $name);
			$contigs{$name} = undef;
		}
		else{
			$contigs{$name} .= $line;
		}
	}
	
	while (my $todo = shift@contigs){
		chomp $todo;
		my $len = length($contigs{$todo});
		my $seq = $contigs{$todo};
		my $correction = 0;
		for(my $i = 0; $i <= $len-($winsize-1); $i += $slide) {
			my $read = substr($seq, $i, $i+($winsize-$correction));
			$count++;
			$correction++;
			print OUT '@SYNTHREAD_'."$count\n";
			print OUT "$read\n";
			print OUT '+'."\n";
			print OUT 'I' x $winsize;
			print OUT "\n";
		}
	}
}

close IN;
close OUT;

exit;