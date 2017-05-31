#!/usr/bin/perl
package gtf_file_processing;

use strict;
use warnings;

### This is the gtf_file_processing.pm, which function as the lib of gtf_rd287.pl.
# Script to read the input gtf file (default input is genes.gtf) and get some statistical data
# according to the flags. The different request will be done by different subroutines stored here.
# Following the instructions given in HW2 B part.
# Tim(Rui Deng) 12/04/2017 [last modified Tim(Rui Deng) 22/04/17]

### This subroutine will do the -g flag work, which is counting the number of genes in the gtf file.
sub get_result_g {
	unless ( -f "$_[0]") {
		print "File not exist:$!\n";
		exit;
	}
    open( IN, "<", "$_[0]" ) || die "cannot open the file: $!\n";
    my %hash1; # Key is the gene_id.
	my $g_cnt;

    while (<IN>) { # Use while rather than foreach to save the space.
		# Use the regular expression to get the information in the input file
		# (which is about 30% faster than using the split).
		# Using "$ time perl gtf_rd287.pl -e" in terminal.
        if ( $_ =~/^\S+\s+\S+\sexon\s+\d+\s+\d+\s+\S\s+\S\s+\S\s+gene_id\s"(\S+)";\s+/ ) {
			$hash1{$1}=1; # Use hash set to count the number of gene with different name.
		}

    }
    close IN; # Close the infile after using.
    $g_cnt = keys %hash1; # Get the number of keys in the hash, which is the number of genes.
    return $g_cnt; # Return the number of genes.
}

### This subroutine will do the -e flag work, which is counting the number of exons in the gtf file.
sub get_result_e {
	unless ( -f "$_[0]") {
		print "File not exist:$!\n";
		exit;
	}
    open( IN, "<", "$_[0]" ) || die "cannot open the file: $!\n";
    my $e_cnt;

    while (<IN>) { # Use while rather than foreach to save the space.

		# Use the regular expression to get the information in the input file
		# (which is about 30% faster than using the split).
		# Using "$ time perl gtf_rd287.pl -e" in terminal.
        if ( $_ =~/^\S+\s+\S+\sexon\s+\d+\s+\d+\s+\S\s+\S\s+\S\s+gene_id\s"(\S+)";\s+/ ) {
        	$e_cnt++; # Count the number of all exons.
        }

    }
    close IN; # Close the infile after using.

    return $e_cnt; # Return the number of exons.
}

### This subroutine will do the -a flag work, which is calculating the average exon length.
sub get_result_a {
	unless ( -f "$_[0]") {
		print "File not exist:$!\n";
		exit;
	}
    open( IN, "<", "$_[0]" ) || die "cannot open the file: $!\n";
    my $e_cnt=0;
    my $sum_e_l=0;
	my %ligate;
	my $s_for_ligate;
    while (<IN>) { # Use while rather than foreach to save the space.

		# Use the regular expression to get the information in the input file
		# (which is about 30% faster than using the split).
		# Using "$ time perl gtf_rd287.pl -a" in terminal.
        if ( $_ =~/^\S+\s+\S+\sexon\s+(\d+)\s+(\d+)\s+\S\s+\S\s+\S\s+gene_id\s"\S+";\s+/ ) {
			# Count the number of the exons.
            # Calculate the sum of the exon length.
			# The length of each exon is calculate by the substruct of two coordinate.
			# Use the abs() to ensure the sum length works.
			$s_for_ligate="$2"."$1";
			unless (exists $ligate{$s_for_ligate}) {
				$e_cnt++;
				$sum_e_l += abs( $2 - $1 )+1;
			}
			$ligate{$s_for_ligate}=1;

        }

    }
    close IN; # Close the infile after using.

	# If there is no exon, this program will end with no numerical result.
	if ( $e_cnt == 0 ) {
		die "There is no exon, so there is no answer for the average length.\n";
	}

	my $avg = $sum_e_l / $e_cnt; # Calculate the average exon length.
    return $avg; # Return the average exon length.
}

### This subroutine will do the -n flag work,
# which is reporting the gene with the highest number of exons.
sub get_result_n {
	unless ( -f "$_[0]") {
		print "File not exist:$!\n";
		exit;
	}
    open( IN, "<", "$_[0]" ) || die "cannot open the file: $!\n";
    my %hash1; # Key(name of gene), Value (the number of exons of that gene).
    my $highest_num_e      = 0;
    my %id_gene_with_h_n_e = ();
    my $tmp_h_cnt          = 0;
	my %ligate;
	my $s_for_ligate;
    while (<IN>) { # Use while rather than foreach to save the space.


		# Use the regular expression to get the information in the input file
		# (which is about 30% faster than using the split).
		# Using "$ time perl gtf_rd287.pl -n" in terminal.
		if ( $_ =~/^\S+\s+\S+\sexon\s+(\d+)\s+(\d+)\s+\S\s+\S\s+\S\s+gene_id\s"(\S+)";\s+/ ) {
			$s_for_ligate="$2"."$1";
			unless (exists $ligate{$s_for_ligate}) {$hash1{$3}++;};
			$ligate{$s_for_ligate}=1;

			 # The number of exons of that gene.

			# if you do not care whether there are several genes share
			# the same maximum number of exons:
			# if ($maxnumber < $hash1{$2}) {$maxnumber = $hash1{$2}; $maxname=$2;
        }

    }

    close IN; # Close the infile after using.

	# Find which key(or keys) has the maxmium value,(which gene(or genes) has highest number of exons).
	# This progress will take a little bit longer time than just found one gene with the highest
	# number with exons.
    foreach ( keys(%hash1) ) {

		if ( $highest_num_e < $hash1{$_} ) {
        	$highest_num_e      = $hash1{$_}; # get the highest number of exons.
            %id_gene_with_h_n_e = ();
            $tmp_h_cnt = 0;
            $id_gene_with_h_n_e{ $tmp_h_cnt++ } = $_;
        }
        elsif ( $highest_num_e == $hash1{$_} ) { # if several genes share the highest number.
        	$id_gene_with_h_n_e{ $tmp_h_cnt++ } = $_; # use array to store them.
        }

    }

	# If there is no exon, this program will end here.
	if ( $highest_num_e == 0 ) {
		die "There is no exon in this file.\n";
	}

	# The ids with thehighest number of exons.
	my @ids_gene_with_h_n_e    = values %id_gene_with_h_n_e;
	print "@ids_gene_with_h_n_e";
	my $referenced_ids_gene_with_h_n_e = \@ids_gene_with_h_n_e; # Reference the array.

	# Return the names of genes with the highest number of exons(referenced) and that highest number.
	return ( $referenced_ids_gene_with_h_n_e, $highest_num_e );

	# if you do not care whether there are several genes share the same maximum number of exons:
	#return ($maxname,$maxnumber );

}


sub get_result_p {
		unless ( -f "$_[0]") {
		print "File not exist:$!\n";
		exit;
	}
    open( IN, "<", "$_[0]" ) || die "cannot open the file: $!\n";
    my $e_cnt_1=0;
    #my $sum_e_l;
	my %ligate;
	my $s_for_ligate;
    while (<IN>) { # Use while rather than foreach to save the space.

		# Use the regular expression to get the information in the input file
		# (which is about 30% faster than using the split).
		# Using "$ time perl gtf_rd287.pl -a" in terminal.
        if ( $_ =~/^\S+\s+\S+\sexon\s+(\d+)\s+(\d+)\s+\S\s+\S\s+\S\s+gene_id\s"\S+";\s+/ ) {
        	#$e_cnt++; # Count the number of the exons.
            # Calculate the sum of the exon length.
			# The length of each exon is calculate by the substruct of two coordinate.
			# Use the abs() to ensure the sum length works.
			$s_for_ligate="$2"."$1";
			unless (exists $ligate{$s_for_ligate}) {$e_cnt_1++;};
			$ligate{$s_for_ligate}=1;

        }

    }
    close IN; # Close the infile after using.

    return $e_cnt_1; # Return the number of exons.
}
#################################
# check the proportion of exon full length (2 for exon, 38 for all gene and gene-related, 62 for intergenic)?
#################################
1;


