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

#########################################################################################################
# Small perl script that the takes the *Compact* output of Sling Request Progress Tracker Log Filter    #
# and returns just the log entries related to the specified HTTP pattern                                #
# eg. 'GET /content/page.html'                                                                          #
#                                                                                                       #
# [1] /system/console/configMgr/org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter      #
#                                                                                                       #
#                                                                                                       #
# Usage:                                                                                                #
#    $ requestprogresstrackerlog-filter.pl '/content/geometrixx-outdoors/en.html' < requesttracker.log  #
#                                                                                                       #
#########################################################################################################

# Each log entry looks liks this

#	19.10.2018 14:41:15.470 *DEBUG* [10.166.218.191 [1539952874531] GET /content/page.html HTTP/1.1] org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter
#		  0 TIMER_START{Request Processing}
#		  0 COMMENT timer_end format is {<elapsed msec>,<timer name>} <optional message>
#		  0 LOG Method=GET, PathInfo=/content/page.html
#		  0 TIMER_START{ResourceResolution}
#		  0 TIMER_END{0,ResourceResolution} URI=/content/page.html resolves to Resource=JcrNodeResource, type=cq:Page, superType=null, path=/content/page
#		  0 LOG Resource Path Info: SlingRequestPathInfo: path='/content/page', selectorString='null', extension='html', suffix='null'
#		  0 TIMER_START{ServletResolution}
#		  0 TIMER_START{resolveServlet(/content/page)}
#		  0 TIMER_END{0,resolveServlet(/content/page)} Using servlet /libs/cq/Page/Page.jsp
#		  0 TIMER_END{0,ServletResolution} URI=/content/page.html handled by Servlet=/libs/cq/Page/Page.jsp
#		  0 LOG Applying Requestfilters
#		  0 LOG Calling filter: com.adobe.granite.resourceresolverhelper.impl.ResourceResolverHelperImpl
#		  0 LOG Calling filter: org.apache.sling.bgservlets.impl.BackgroundServletStarterFilter
#		  0 LOG Calling filter: com.adobe.granite.rest.impl.servlet.ApiResourceFilter
#		  0 LOG Calling filter: org.apache.sling.i18n.impl.I18NFilter
#		  0 LOG Calling filter: com.adobe.granite.httpcache.impl.InnerCacheFilter
#		  0 LOG Calling filter: org.apache.sling.rewriter.impl.RewriterFilter
#		  0 LOG Calling filter: com.adobe.cq.mcm.campaign.servlets.CampaignCopyTracker
#		  0 LOG Calling filter: com.day.cq.wcm.core.impl.WCMRequestFilter
#		  0 LOG Calling filter: com.adobe.fd.core.security.internal.CurrentUserServiceImpl

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Data::Dumper;

my $reqPattern = $ARGV[0];

print STDERR "Searching for '$reqPattern'\n";

my $open = 0;
my $i = 0;
my $out = 0;


while( my $line = <STDIN>)  {
	#print $line;
	chomp $line;
	$i++;

	if ($line =~ /^[0-9.]{2}.* \*DEBUG\* \[.*$reqPattern.*\] org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter.*$/) {
		$open = 1;
	}
	elsif ($line =~ /^[0-9.]{2}.* \*DEBUG\* \[.*\] org.apache.sling.engine.impl.debug.RequestProgressTrackerLogFilter.*$/) {
		$open = 0;
	}

#	print STDERR "Status $open : '$line'\n";

	if ($open) {
		$out++;
		print "$line\n";
	}

}

print STDERR "Wrote $out lines\n";
