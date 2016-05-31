Genomics
========

Contains miscellaneous scripts for genomics

FASTQtoFASTA.pl         - Converts FASTQ files to FASTA/QUAL files. Autodetects Sanger/illumina encoding

orientRNAs              - Reorient RNAs in a multifasta file according to their top blast hits

removeTP.pl            - Removes NexteraXT transposon sequences from FASTQ files

runTaxonomizedBLAST.pl  - Runs NCBI blast locally with taxonomic IDs (requires locally-installed NCBI NR, NT and TaxDB databases)

SeqIO.pl                - Interconverts common formats. Based on BioPerl's SeqIO module. Requires local installation of BioPerl

splitMultifasta         - Splits a multifasta file into separate fasta (*.fsa) files

sort_by_coverage.pl     - Filters the Contigs.tsv file generated by Ray according to the desired coverage range and minimum length

