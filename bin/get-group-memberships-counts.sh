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
# 
#  Outputs a TSV of AEM Groups and their Direct and Indirect(Total) memberships
# 
# Usage:
#    $ get-group-memberships-counts.sh <aem url> <user> <base path>
#    $ get-group-memberships-counts.sh http://localhost:4502 admin:admin
#    $ get-group-memberships-counts.sh http://localhost:4502 admin:admin /home/groups

set -ue

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"
AEM_PATH="${3:-/home/groups}"

echo -e "Title\tName\tNumberTotalMemberships\tNumberDirectMemberships"

# set -x
curl -sSf -G -u "${AEM_USER}" \
"${AEM_HOST}/bin/querybuilder.json" \
-d 'p.limit=-1' \
-d 'type=rep:Group' \
-d "path=${AEM_PATH}" \
| jq -r '.hits[] | .path' | dos2unix | sort | while read groupPath
do
  # echo "$groupPath";

  curl -sSf -G -u "${AEM_USER}" \
  "${AEM_HOST}${groupPath}.rw.json" \
  -d 'props=memberOf,declaredMemberOf' \
  | jq -r '.name + "\t" + .authorizableId + "\t" + (.memberOf | length | tostring) + "\t" + (.declaredMemberOf | length | tostring)' | dos2unix

done;
