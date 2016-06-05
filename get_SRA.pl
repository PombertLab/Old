#!/usr/bin/perl
## Pombert JF, Illinois Tech - 2016
## Downloads SRA files from the NCBI FTP site 

use strict;
use warnings;
use Getopt::Long qw(GetOptions);  

my $usage = '
USAGE = get_SRA.pl -l accession_list(s)

-l (--list)	List(s) of SRA accesssion numbers, one accession number per line
';
die "$usage\n" unless @ARGV;

my @list;
GetOptions(
'l|list=s' => \@list,
);

my $ftp = 'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/';
my $prefix = undef;
my $run = undef;
my $id = undef;
my $sra = undef;

while (my $list = shift@list){ 
	open IN, "<$list";
	while (my $line = <IN>){
		chomp $line;
		if ($line =~ /^(\w{3})(\w{3})(\w{3,})/){
			$prefix = $1;
			$run = $2;
			$id = $3;
			$sra = "$line.sra";
			my $url = "$ftp$prefix".'/'."$prefix$run".'/'."$line".'/'."$sra";
			system "echo Downloading $sra...";
			system "wget $url"; 
		}
	}
}