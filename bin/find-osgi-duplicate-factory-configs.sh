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
# Small bash script to find duplicate OSGI Factory configurations in AEM                 #
#                                                                                        #
# Expects to be executed in the AEM Parent folder (the one containing 'crx-quickstart')  #
#                                                                                        #
# Performs no changes, just creates a report.                                            #
#                                                                                        #
##########################################################################################

set -ue

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"

LAUNCHPAD_CONFIG="crx-quickstart/launchpad/config"

ls -ald "$LAUNCHPAD_CONFIG" >> /dev/null  # rely on bash exit on error code

TMPDIR="${TMP:-/tmp}/find-osgi-duplicate-configs"
TMPFILE=$TMPDIR/tmp

if [ -e $TMPDIR ]; then
  rm -r $TMPDIR
fi

mkdir -p $TMPDIR

curl -s -S -f -u "$AEM_USER" -o "$TMPDIR/status-osgi-installer.txt" "$AEM_HOST/system/console/status-osgi-installer.txt"

dos2unix -q $TMPDIR/status-osgi-installer.txt

touch $TMPFILE.names   # so first 'rm' works

for d in `find $LAUNCHPAD_CONFIG -name factory.config | xargs dirname`; do

  rm $TMPFILE.*

  for f in `ls -1 $d | grep -v factory.config`; do

    md5=`fgrep -v service.pid $d/$f | dos2unix | md5sum | awk '{print $1}'`
    echo "$md5" >> $TMPFILE.md5s
    echo "$md5 $d/$f" >> $TMPFILE.names

  done;

  sort $TMPFILE.md5s | uniq -d > $TMPFILE.md5s.dupes

  if [ -s $TMPFILE.md5s.dupes ]; then

    for m in `cat $TMPFILE.md5s.dupes`; do 

      dupes=`grep "^$m" $TMPFILE.names | sort | awk '{ print $2 }'`

      for dupe in $dupes; do
        servicePid=`fgrep "service.pid=" $dupe | dos2unix | perl -pe 's/^service.pid="(.*)"$/$1/'`
        echo "$dupe"
        echo "    $AEM_HOST/system/console/configMgr/$servicePid"
        fgrep "$servicePid" "$TMPDIR/status-osgi-installer.txt" | perl -pe 's/^/    /'
        echo
      done;

      echo "  ---------"

    done

  fi

done;

rm -r $TMPDIR
