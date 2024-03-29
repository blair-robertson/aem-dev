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

##########################################################################################################
# Small perl script that the takes the *Compact* output of Sling Request Progress Tracker Log Filter [1]
# and creates a "collapsed stack format" [2] version of the TIMER_START and TIMER_END results for use in 
# FlameGraph [3] or SpeedScope [4]
#
# Inspired heavily from stackcollapse-jstack.pl[5]
#																										
# [1] /system/console/configMgr/org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter		
# [2] https://github.com/brendangregg/FlameGraph#2-fold-stacks
# [3] http://www.brendangregg.com/flamegraphs.html
# [4] https://www.speedscope.app/         https://github.com/jlfwong/speedscope/
# [5] https://github.com/brendangregg/FlameGraph/blob/master/stackcollapse-jstack.pl
#																										
# Usage:																								
#    $ requestprogresstrackerlog-timers-stackcollapse.pl < requesttracker.log > collapsed-stack.txt #
#																										
##########################################################################################################


use strict;
use warnings;
use Data::Dumper;
use POSIX qw(ceil);


# internals
my %collapsed;

sub remember_stack {
	my ($stack, $count) = @_;
	$collapsed{$stack} += ($count / 1000);
}

my @stack;
my @stack_sub_time;

my $i = 0;
my $lineno = 0;
while( my $line = <STDIN>)  {
#    print $line;
	chomp $line;
	$lineno++;

	if ($line =~ /^[0-9.]{2}.* \*DEBUG\* \[.*\] org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter _(.*)$/) {

		my @entries = split(/_(?=\s*[0-9]+ (?:TIMER_START|TIMER_END|LOG|COMMENT))/, $1);
		# print Dumper(\@entries);

		foreach my $entry (@entries) {

			if ($entry =~ /^\s*[0-9]+ TIMER_START\{(.+)\}.*$/) {
				my ($timer_name) = ($1);
				$timer_name =~ s/;//;
				push @stack, $1;
				push @stack_sub_time, 0;
			}
			elsif ($entry =~ /^\s*[0-9]+ TIMER_END\{([0-9]+),(.+)\}.*/) {
				my ($time_taken, $timer_name) = ($1, $2);
				$timer_name =~ s/;//;

				my $collapsed_stack = join(";", @stack);
				my $last_timer = pop @stack;
				my $sub_time = pop @stack_sub_time;

				if ($timer_name ne $last_timer) {
					die "Unexpected TIMER_END - Line $lineno.\nCurrent Stack : $collapsed_stack\nExpected Timer : '$last_timer'\nFound Timer : $entry\n";
				}

				if (@stack_sub_time) {
					$stack_sub_time[-1] += $time_taken;
				}

				# print "-------\n";
				# print "$time_taken - $sub_time >> " .($time_taken - $sub_time)." >> $collapsed_stack\n";
				# print Dumper(\@stack);
				# print Dumper(\@stack_sub_time);
				remember_stack($collapsed_stack, $time_taken - $sub_time);

			}

		}
	} else {
		print STDERR "Unregonized line : $line\n";
	}

}

foreach my $k (sort { $a cmp $b } keys %collapsed) {
	printf "%s %.0f\n", $k, $collapsed{$k};
}
