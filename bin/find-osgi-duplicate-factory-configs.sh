#!/bin/bash
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
# Small bash+perl script to find duplicate OSGI Factory configurations in AEM            #
#                                                                                        #
# Performs no changes, just creates a report.                                            #
#                                                                                        #
# Usage:                                                                                 #
#    $ find-osgi-duplicate-factory-configs.sh <aem url> <user> <work dir for tmp files>  #
#    $ find-osgi-duplicate-factory-configs.sh http://localhost:4502 admin:admin          #
#    $ find-osgi-duplicate-factory-configs.sh http://localhost:4502 admin:admin .        #
#                                                                                        #
##########################################################################################

set -ue

SCRIPT_DIR=`dirname "$0"`

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"
WORKDIR="${3:-.}"

mkdir -pv "$WORKDIR"
cd "$WORKDIR"

curl -s -S -f -u "$AEM_USER" -o "status-osgi-installer.txt" "$AEM_HOST/system/console/status-osgi-installer.txt"
curl -s -S -f -u "$AEM_USER" -o "status-configurations.txt" "$AEM_HOST/system/console/status-Configurations.txt"

dos2unix -q status-*.txt

"$SCRIPT_DIR/find-osgi-duplicate-factory-configs.pl" < status-configurations.txt > duplicate-factory-configs.txt

while IFS=';' read -a dupePids
do

  echo "## Found #${#dupePids[@]} duplicates ##";

  for servicePid in "${dupePids[@]}"; do
    echo "$servicePid"
    echo "    $AEM_HOST/system/console/configMgr/$servicePid"
    fgrep "$servicePid" status-osgi-installer.txt | perl -pe 's/^/    /'
    echo
  done;

done < duplicate-factory-configs.txt

