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

set -ue

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin}"
AEM_PASSWORD="${3:-admin}"
AEM_PATH="${4:-/content/we-retail}"

# set -x
curl -sSf -G -u "${AEM_USER}:${AEM_PASSWORD}" \
"${AEM_HOST}/bin/acs-commons/jcr-compare.dump.json" \
-d 'optionsName=REQUEST' \
-d "paths=${AEM_PATH}" \
-d 'nodeTypes=cq:PageContent' \
-d 'nodeTypes=dam:AssetContent' \
-d 'nodeTypes=cq:Tag' \
-d 'excludeNodeTypes=rep:ACL' \
-d 'excludeNodeTypes=cq:meta' \
-d 'excludeProperties=jcr:mixinTypes' \
-d 'excludeProperties=jcr:created' \
-d 'excludeProperties=jcr:createdBy' \
-d 'excludeProperties=jcr:uuid' \
-d 'excludeProperties=jcr:lastModified' \
-d 'excludeProperties=jcr:lastModifiedBy' \
-d 'excludeProperties=cq:lastModified' \
-d 'excludeProperties=cq:lastModifiedBy' \
-d 'excludeProperties=cq:lastReplicated' \
-d 'excludeProperties=cq:lastReplicatedBy' \
-d 'excludeProperties=cq:lastReplicationAction' \
-d 'excludeProperties=cq:lastRolledout' \
-d 'excludeProperties=cq:lastRolledoutBy' \
-d 'excludeProperties=cq:lastReplicatedBy' \
-d 'excludeProperties=jcr:versionHistory' \
-d 'excludeProperties=jcr:predecessors' \
-d 'excludeProperties=jcr:baseVersion' \
-d 'excludeProperties=jcr:isCheckedOut' \
-d 'sortedProperties=cq:tags' \
| perl -pe "s!${AEM_PATH}!nodepath!g"
