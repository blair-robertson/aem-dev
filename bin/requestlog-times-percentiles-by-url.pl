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
#  Takes input from rlog.jar and calculates the given timeTaken percentiles by individual URL.
#  Performs NO filtering on URLS - assumes is done externally.
#
#  Logic: http://www.dummies.com/how-to/content/how-to-calculate-percentiles-in-statistics.html
#
#  Usage:
#		 $ java -jar <AEM>/crx-quickstart/opt/helpers/rlog.jar request.log > request.log.processed
#        $ requestlog-times-percentiles-by-url.pl 85 90 95 < request.log.processed
#
use strict;
use warnings;
use Data::Dumper;
use POSIX qw(ceil);


die ("No percentiles passed as arguments") unless (scalar(@ARGV));

my $times = ();

while( my $line = <STDIN>)  {
#    print $line;
	chomp $line;
		
	if ($line =~ /^\s+([0-9]+)ms ([^\s]+ \+[0-9]{4}) ([0-9]{3}) ([A-Z]+) ([^\s]+) .+$/) {
		my ($timeTaken, $date, $status, $httpMethod, $url) = ($1, $2, $3, $4, $5);
		
		# strip querystring
		$url =~ s/\?.*//;

		if (!defined($times->{$url})) {
			$times->{$url} = ();
		}
		push @{$times->{$url}}, $timeTaken;

	}
	else {
		print STDERR "Ignored line : $line\n";
	}
	
}

print join("\t", ("URL", "Total calls", map {$_."%"} @ARGV))."\n";

# print Dumper($times);

for my $url (sort {$a cmp $b} keys %$times) {

	my @sorted_times = sort {$a <=> $b} @{$times->{$url}};
	my $num_calls = scalar @sorted_times;

	#print "SORT:ED ".$sorted_times[3]."\n";
	#print Dumper(\@sorted_times);

#	printf "Total Calls: % 5d   %s\n", $num_calls, $url;

	print "$url\t$num_calls\t";

	for my $PERCENTILE (@ARGV) {

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

		printf "%6.0f\t", $result;

	}
	print "\n";
}

exit;

