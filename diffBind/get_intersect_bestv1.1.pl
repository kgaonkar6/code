#!/usr/bin/perl
use strict;
use warnings;
## Perl script to generate the files required for diffBind
## Krutika Gaonkar 1/27/2016
use Data::Dumper;

if (scalar(@ARGV) != 4)	
{
	die ( "USAGE: get_intersect_best.pl [bed for mark] [caller] [mergedBed]  [output dir]\n" );
}


my $peak_bed = $ARGV[0];
my $caller= $ARGV[1];
my $merged_bed=$ARGV[2];
my $dir=$ARGV[3];


my $sample=`basename $peak_bed|cut -d "." -f1`;
chomp ($sample);
my $name=$sample.".bed";
`intersectBed -wo -a $merged_bed -b $peak_bed > $dir/intersect_$name`;
open BED, "$dir/intersect_$name" or die;
open BEST, ">" ,"$dir/best_$name" or die;

my %cons_peak_info = ();
### chr_merged.start_merged.end -> [best FDR/qvalue]

my $FDR=0;



while (<BED>){
        my $row = $_;
        chomp $row;
        my @line = split("\t",$row);
	my $q_val=$line[7];
        if ( !$cons_peak_info{"$line[0]_$line[1]_$line[2]"}) {$cons_peak_info{"$line[0]_$line[1]_$line[2]"} = "$q_val";}
        
	if ( $cons_peak_info{"$line[0]_$line[1]_$line[2]"} < $q_val )
        	{
                $cons_peak_info{"$line[0]_$line[1]_$line[2]"} = "$q_val";
		}
	}



foreach my $region ( sort keys %cons_peak_info)
{
my $value=$cons_peak_info{$region};
$region =~s/_/\t/g;
print BEST "$region\t$value\n";
}

###`rm $dir/intersect_$name`;
