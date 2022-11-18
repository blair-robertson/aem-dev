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


###################################################################################################
# Small bash script to find OSGI bundles and configurations that exist in AEM but not
# installed by the OSGI Installer (i.e. do not exist in Launchpad or JCR)
#
# Performs no changes, just creates a report.
#
# Usage:
#    $ check-missing-osgi-installed-bundles-configs.sh <aem url> <user> <work dir for tmp files> > status-bundles-configs.txt
#    $ check-missing-osgi-installed-bundles-configs.sh http://localhost:4502 admin:admin         > status-bundles-configs.txt
#    $ check-missing-osgi-installed-bundles-configs.sh http://localhost:4502 admin:admin .       > status-bundles-configs.txt
#
#    $ grep MISSING status-bundles-configs.txt
###################################################################################################

set -ue
shopt -s lastpipe

SCRIPT_DIR=`dirname "$0"`

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"
WORKDIR="${3:-.}"

mkdir -pv "$WORKDIR" >&2
cd "$WORKDIR"

curl -s -S -f -u "$AEM_USER" -o "status-osgi-installer.txt" "$AEM_HOST/system/console/status-osgi-installer.txt"
curl -s -S -f -u "$AEM_USER" -o "status-configurations.txt" "$AEM_HOST/system/console/status-Configurations.txt"
curl -s -S -f -u "$AEM_USER" -o "bundles.json" "$AEM_HOST/system/console/bundles/.json"
dos2unix -q status-*.txt

jq -r '.data | sort_by(.id)[] | .id' < bundles.json | dos2unix > bundleids.txt

for bundleId in `cat bundleids.txt`; do
  echo "Bundle : $bundleId" >&2
  curl -s -S -f -u "$AEM_USER" -o "bundle-${bundleId}.json" "$AEM_HOST/system/console/bundles/${bundleId}.json"

  # needs 'lastpipe' above
  jq -r '.data[0] | .symbolicName + "\t" + (.props | from_entries | .["Bundle Location"])' < "bundle-${bundleId}.json" | dos2unix | read symbolicName bundleLocation

  osgiInstaller=`fgrep "* $symbolicName: " status-osgi-installer.txt | cat`   # 'cat' to always return non zero error code
  if [ -z "$osgiInstaller" ]; then
    echo "MISSING : Bundle #$bundleId: $symbolicName ($bundleLocation)"
  else
    echo "FOUND   : Bundle #$bundleId: $symbolicName ($bundleLocation) > $osgiInstaller"
  fi


done

for configPid in `perl -ne 'print "$1\n" if (/^PID = (.*)$/);' < status-configurations.txt`; do
  echo "Config : $configPid" >&2
  osgiInstaller=`fgrep "$configPid: " status-osgi-installer.txt | cat`   # 'cat' to always return non zero error code
  if [ -z "$osgiInstaller" ]; then
    echo "MISSING : Config : $configPid"
  else
    echo "FOUND   : Config : $configPid > $osgiInstaller"
  fi
done;

