#!/usr/bin/perl
########################################################################################
# MIT License                                                                          #
#                                                                                      #
# Copyright (c) Blair Robertson 2018                                                   #
#                                                                                      #
# Permission is hereby granted, free of charge, to any person obtaining a copy         #
# of this software and associated documentation files (the "Software"), to deal        #
# in the Software without restriction, including without limitation the rights         #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell            #
# copies of the Software, and to permit persons to whom the Software is                #
# furnished to do so, subject to the following conditions:                             #
#                                                                                      #
# The above copyright notice and this permission notice shall be included in all       #
# copies or substantial portions of the Software.                                      #
#                                                                                      #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR           #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,             #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE          #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER               #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,        #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE        #
# SOFTWARE.                                                                            #
########################################################################################
#
#  Takes input from rlog.jar and calculates the given timeTaken percentiles for all requests.
#  Performs NO filtering on URLS - assumes is done externally.
#
#  Logic: http://www.dummies.com/how-to/content/how-to-calculate-percentiles-in-statistics.html
#
#  Usage:
#		 $ java -jar <AEM>/crx-quickstart/opt/helpers/rlog.jar request.log > request.log.processed
#        $ requestlog-times-percentiles.pl 85 90 95 < request.log.processed
#
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(ceil);



my @times = (); 

my $num_calls = 0;
while( my $line = <STDIN>)  {
#    print $line;
	chomp $line;

	if ($line =~ /^\s+([0-9]+)ms .+$/) {
		push @times, $1;
		$num_calls++;
	}
	else {
		print STDERR "Ignored line : $line\n";
	}
}

my @sorted_times = sort {$a <=> $b} @times;

#print "SORT:ED ".$sorted_times[3]."\n";
#print Dumper(\@sorted_times);

print "Total Calls: $num_calls\n";

while (my $PERCENTILE = shift @ARGV) {

	my $index = $num_calls * ($PERCENTILE / 100);

	my $ceil = ceil($index);
	my $result;

	# perl zero-based indexes...
	$index--;
	$ceil--;

	if ($index == $ceil) {
		# index is whole number, average index and value above
		$result = ($sorted_times[$index] + $sorted_times[$index + 1]) / 2;
	}
	else {
		# index is fraction, take ceil
		$result = $sorted_times[$ceil];
	}

	printf "%d\t%6.0f\n", $PERCENTILE, $result;

}
