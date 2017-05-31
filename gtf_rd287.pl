#!/usr/bin/perl

use strict;
use warnings;

### This is the gtf_rd287.pl, which will use the lib gtf_file_processing.pm.
# Script to read the input gtf file (default input is genes.gtf) and get some statistical data
# according to the flags. The different request will be done by different subroutines stored in
# the lib gtf_file_processing.pm file.
# Following the instructions given in HW2 B part.
# Tim(Rui Deng) 12/04/2017 [last modified Tim(Rui Deng) 22/04/17]

use lib "./";
use gtf_file_processing;
use Getopt::Std;
use vars qw($opt_g $opt_e $opt_a $opt_n $opt_h);
getopts('geanh');
my $usage = "
wrong input,(should be [-g,-e,-a,-n,-h]) . 
Use -h for some helpful instructions.\n
";
my $detailedusage = "
Usage: gtf_rs206.pl [options]\noptions: [-g,-e,-a,-n,-h] filename (optional)
The reporting of results is directed by these flags: 
Reports the number of genes in the gtf file.[-g] 
Reports the number of exons.[-e] 
Reports the average exon length. [-a]
Reports the gene with the highest number of exons. [-n]
";
my $filename = 'genes.gtf';    # default input name.

unless ( $opt_g or $opt_e or $opt_a or $opt_n or $opt_h ) {
    die $usage;
}

# -h for printing out some helpful instructions.
if ($opt_h) {
    print "$detailedusage\n";
    exit;
}
my $choice1;                   # Choice for whether change the inputfile.


# If the user input the inputfile name in command argument, use that file.
if ( exists $ARGV[0] ) {
    if ( $ARGV[0] =~ /\.gtf$/ ) { 
		$filename = $ARGV[0]; 
	}
    else { 
		print "File in wrong format.\n"; 
		exit; 
	}
}
else {
    # Ask the user if they want to change the input name.
    print "Do you want to change the default input file ($filename)?\n";
    do {
        print "\n\tPlease type Y/N.\n";
        $choice1 = <STDIN>;
        chomp($choice1);
      } until ( $choice1 eq 'Y' || $choice1 eq 'N' )
      ;    # Keep asking until getting 'Y' or 'N'.
    if ( $choice1 eq 'Y' ) {
        do {
            print "type the new name.(ending with .gtf)\n";
			print "There are the candidate file names:\n\n\t";
            system("ls *.gtf");
            $filename = <STDIN>;
            chomp($filename);    # get the file name of the new inputfile.
          } until ( $filename =~ /\.gtf$/ )
          ;    # Keep asking until get the name of inputfile in right format.
        print "Change the new input file name to $filename\n";
    }
}

### Do the task according to the flags.

# -g for reporting the number of genes in the gtf file.
if ($opt_g) {
    printf( "number of genes\t: %4.0f\n",
        &gtf_file_processing::get_result_g($filename) );
}

# -e for reporting the number of exons.
if ($opt_e) {
    printf( "number of exons\t: %4.0f\n",
        &gtf_file_processing::get_result_e($filename) );
}

# -a for reporting the average exon length.
if ($opt_a) {
    printf( "average exon length\t= %4.2f\n",
        &gtf_file_processing::get_result_a($filename) );
}

# -n for reporting the gene with the highest number of exons.
if ($opt_n) {
    my ( $referenced_names, $highest_number ) =
      &gtf_file_processing::get_result_n($filename);

# If the multiple maximum highest number not matters:
# Print "The name of that gene which has highest numbers of exons:\t$referenced_names\n";
    print "highest numbers of exons:\t$highest_number\n";

    # Print the names(1 to many) of gene who has the highest number of exons.
	# Dereference the array and print each element there.
    foreach ( @{$referenced_names} ) {    
        print "id of that gene:\t$_\n";
    }
}

