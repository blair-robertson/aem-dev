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

##########################################################################################
# Small perl script that takes the output of Felix Console: Status > Configurations [1]  #
# and produces a list of OSGI Factory configurations that are exactly the same           #
#																						 #
# [1] http://localhost:4502/system/console/status-Configurations.txt					 #
##########################################################################################


use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Data::Dumper;

my $factoryConfigs = {};

my $pid = "";
my $pidDetails = "";

my $i = 0;

while( my $line = <STDIN>)  {
    #print $line;
	chomp $line;
	$i++;

	if ($line =~ /^PID = (.*)$/) {
		$pid = $1;
		$pidDetails = "";

	}
	elsif ($pid ne "" && $line eq "") {
		# end of PID

		if ($pidDetails =~ /Factory PID = (.*)/) {
			# PID is part of factory config

			my $factoryPid = $1;
			$pidDetails =~ s/$pid//;
			my $pidDetailsMd5 = md5_hex($pidDetails);

			unless ($factoryConfigs->{$factoryPid}) {
				$factoryConfigs->{$factoryPid} = {};
			}
			unless ($factoryConfigs->{$factoryPid}->{$pidDetailsMd5}) {
				$factoryConfigs->{$factoryPid}->{$pidDetailsMd5} = [];
			}

			push @{$factoryConfigs->{$factoryPid}->{$pidDetailsMd5}}, $pid;
		
		}

		$pid = "";
		$pidDetails = "";
	}
	elsif ($pid ne "") {

		$pidDetails .= "$line\n";

	}
	

}

# print Dumper($factoryConfigs)."------------\n";

for my $factoryPid (sort keys %$factoryConfigs) {
#	print "$factoryPid\n";
	for my $md5 (keys %{$factoryConfigs->{$factoryPid}}) {
		my $dupePids = $factoryConfigs->{$factoryPid}->{$md5};
		print join(";", @$dupePids)."\n" if (scalar @$dupePids > 1);
	}
}
