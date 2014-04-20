#!/usr/bin/perl

## Pombert Lab, IIT, 2014

## Converts EMBL files to NCBI TBL format for TBL2ASN
## NOTE: Requires the EMBL and the corresponding fasta inputs (*.fsa) in the same folder

use strict;
use warnings;
use Bio::SeqIO;

my $instID = 'IITBIO'; ## Insert desired institute ID here
my $products = "products_list.txt"; ## Insert product list here

my $usage = 'USAGE = EMBLtoTBL *.embl';
die $usage unless @ARGV;

sub numSort {
		if ($a < $b) { return -1; }
		elsif ($a == $b) { return 0;}
		elsif ($a > $b) { return 1; }
}

### Products list
my %hash = ();
open HASH, "<$products";
while (my $dbkey = <HASH>){
	chomp $dbkey;
	if ($dbkey =~ /^(\S+)\t(.*)$/){
		my $prot = $1;
		my $prod = $2;
		$hash{$prot}=$prod;
	}
}

while (my $file = shift@ARGV){
	open IN, "<$file";
	$file =~ s/.embl$//;
	open DNA, "<$file.fsa";
	open TBL, ">$file.tbl";
	print TBL ">Feature $file\n"; ## Generate TBL header
	
	### Creating a single DNA string for protein translation
	my $DNAseq= undef;
	while (my $dna = <DNA>){
		chomp $dna;
		if ($dna =~ /^>/){next;}
		else{$DNAseq.= $dna;}
	}
	my $DNAsequence = lc($DNAseq); ## Changing to lower case to fit with the translation hash
	my $contig_length = length($DNAsequence); ## Calculating the contig size
	my $locus_tag = undef;
	my $protein = undef;
	while (my $line = <IN>){
		chomp $line;
		my @start = ();
		my @stop = ();
		my $asize = undef;
		my $num = undef;
		my $dum = undef;
		if ($line =~ /FT\s+\/locus_tag="(\DI09_\d+p\d+)"/){
			$locus_tag = $1;
		}
		elsif ($line =~ /FT\s+CDS\s+(\d+)..(\d+)/){ ## Forward, single exon
			my $start = $1;
			my $stop = $2;
			my $startcodon = substr($DNAsequence, $start-1, 3);
			my $stopcodon = substr($DNAsequence, $stop-3, 3);
			print TBL "<$start\t>$stop\tgene\n";
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			print TBL "<$start\t>$stop\tmRNA\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
			if (($startcodon eq 'atg') && (($stopcodon eq 'taa') || ($stopcodon eq'tag') || ($stopcodon eq'tga'))){ ## =, =
				print TBL "$start\t$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			elsif (($startcodon ne 'atg') && (($stopcodon eq 'taa') || ($stopcodon eq'tag') || ($stopcodon eq'tga'))){ ## !=, =
				print TBL "<$start\t$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			elsif ($startcodon eq 'atg'){ ## =, !=
				print TBL "$start\t>$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			else{ ## !=, !=
				print TBL "<$start\t>$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			print TBL "\t\t\tprotein_id\tgnl|$instID|$locus_tag\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
		}
		elsif ($line =~ /FT \s+CDS\s+complement\((\d+)..(\d+)\)/){ ## Reverse, single exon
			my $start = $2;
			my $stop = $1;
			my $startcodon = substr($DNAsequence, $start-3, 3);
			my $stopcodon = substr($DNAsequence, $stop-1, 3);
			print TBL "<$start\t>$stop\tgene\n";
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			print TBL "<$start\t>$stop\tmRNA\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
			if (($startcodon eq 'cat') && (($stopcodon eq 'tta') || ($stopcodon eq'cta') || ($stopcodon eq'tca'))){ ## =, =
				print TBL "$start\t$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			elsif (($startcodon ne 'cat') && (($stopcodon eq 'tta') || ($stopcodon eq'cta') || ($stopcodon eq'tca'))){ ## !=, =
				print TBL "<$start\t$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			elsif ($startcodon eq 'cat'){ ## =, !=
				print TBL "$start\t>$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			else{ ## !=, !=
				print TBL "<$start\t>$stop\tCDS\n";
				print TBL "\t\t\tlocus_tag\t$locus_tag\n";
				if (exists $hash{$locus_tag}){
					print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";
				}
				else{
					print TBL "\t\t\tproduct\thypothetical protein\n";
				}
			}
			print TBL "\t\t\tprotein_id\tgnl|$instID|$locus_tag\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
		}	
		elsif ($line =~ /FT\s+CDS\s+join\((.*)\)/){ ## Forward, multiple exon
			my @array = split(',',$1);
			my $mRNA = undef;
			while (my $segment = shift@array){
				chomp $segment;
				if ($segment =~ /(\d+)..(\d+)/){
					my $strt = $1;
					my $stp = $2;
					push (@start, $strt);
					push (@stop, $stp);
				}
			}
			$asize = scalar(@start);
			$num = ($asize -1);
			$dum = ($asize -2);

			### Printing gene info
			print TBL "<$start[0]\t>$stop[$num]\tgene\n";
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			
			### Printing mRNA info
			if ($asize == 1){print TBL "<$start[0]\t>$stop[0]\tmRNA\n";}
			elsif ($asize == 2){print TBL "<$start[0]\t$stop[0]\tmRNA\n"; print TBL "$start[1]\t>$stop[1]\n";}
			elsif ($asize >= 3){
				print TBL "<$start[0]\t$stop[0]\tmRNA\n";
				foreach my $subs (1..$dum){print TBL "$start[$subs]\t$stop[$subs]\n";}
				print TBL "$start[$num]\t>$stop[$num]\n";	
			}
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
			
			### Printing CDS info
			my $startcodon = substr($DNAsequence, $start[0]-1, 3);
			my $stopcodon = substr($DNAsequence, $stop[$num]-3, 3);
			if ($startcodon eq 'atg'){print TBL "$start[0]\t$stop[0]\tCDS\n";} ## printing the 1st exon
			else{print TBL "<$start[0]\t$stop[0]\tCDS\n";} ## printing the 1st exon
			if ($asize == 2){ ## Do we have only two exons?
				if (($stopcodon eq 'taa') || ($stopcodon eq'tag') || ($stopcodon eq'tga')){print TBL "$start[$num]\t$stop[$num]\n";} ## printing the last exon
				else{print TBL "$start[$num]\t>$stop[$num]\n";} ## printing the last exon	
			}
			elsif ($asize >= 3){
				foreach my $subs (1..$dum){print TBL "$start[$subs]\t$stop[$subs]\n";}
				if (($stopcodon eq 'taa') || ($stopcodon eq'tag') || ($stopcodon eq'tga')){print TBL "$start[$num]\t$stop[$num]\n";} ## printing the last exon
				else{print TBL "$start[$num]\t>$stop[$num]\n";} ## printing the last exon	
			}
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			if (exists $hash{$locus_tag}){print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";}
			else{print TBL "\t\t\tproduct\thypothetical protein\n";}
			print TBL "\t\t\tprotein_id\tgnl|$instID|$locus_tag\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
		}
		elsif ($line =~ /FT\s+CDS\s+complement\(join\((.*)/){ ## Reverse, mutiple exon
			my @array = split(',',$1);
			my $mRNA = undef;
			while (my $segment = shift@array){
				chomp $segment;
				if ($segment =~ /(\d+)..(\d+)/){
					my $strt = $2;
					my $stp = $1;
					unshift (@start, $strt);
					unshift (@stop, $stp);
				}
			}
			$asize = scalar(@start);
			$num = ($asize -1);
			$dum = ($asize -2);
			my @sstart = sort numSort @start;
			my @sstop = sort numSort @stop;
			
			### Printing gene info
			print TBL "<$start[0]\t>$stop[$num]\tgene\n";
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			
			### Printing mRNA info
			if ($asize == 1){print TBL "<$start[0]\t>$stop[0]\tmRNA\n";}
			elsif ($asize == 2){print TBL "<$start[0]\t$stop[0]\tmRNA\n"; print TBL "$start[1]\t>$stop[1]\n";}
			elsif ($asize >= 3){
				print TBL "<$start[0]\t$stop[0]\tmRNA\n";
				foreach my $subs (1..$dum){print TBL "$start[$subs]\t$stop[$subs]\n";}
				print TBL "$start[$num]\t>$stop[$num]\n";	
			}
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
			
			### Printing CDS info
			my $startcodon = substr($DNAsequence, $start[0]-3, 3);
			my $stopcodon = substr($DNAsequence, $stop[$num]-1, 3);
			if ($startcodon eq 'cat'){print TBL "$start[0]\t$stop[0]\tCDS\n";} ## printing the 1st exon
			else{print TBL "<$start[0]\t$stop[0]\tCDS\n";} ## printing the 1st exon
			if ($asize == 2){ ## Do we have only two exons?
				if (($stopcodon eq 'tta') || ($stopcodon eq'cta') || ($stopcodon eq'tca')){print TBL "$start[$num]\t$stop[$num]\n";} ## printing the last exon
				else{print TBL "$start[$num]\t>$stop[$num]\n";} ## printing the last exon	
			}
			elsif ($asize >= 3){
				foreach my $subs (1..$dum){print TBL "$start[$subs]\t$stop[$subs]\n";}
				if (($stopcodon eq 'tta') || ($stopcodon eq'cta') || ($stopcodon eq'tca')){print TBL "$start[$num]\t$stop[$num]\n";} ## printing the last exon
				else{print TBL "$start[$num]\t>$stop[$num]\n";} ## printing the last exon	
			}
			print TBL "\t\t\tlocus_tag\t$locus_tag\n";
			if (exists $hash{$locus_tag}){print TBL "\t\t\tproduct\t$hash{$locus_tag}\n";}
			else{print TBL "\t\t\tproduct\thypothetical protein\n";}
			print TBL "\t\t\tprotein_id\tgnl|$instID|$locus_tag\n";
			print TBL "\t\t\ttranscript_id\tgnl|$instID|$locus_tag"."_mRNA\n";
		}
	}
}
close IN;
close TBL;