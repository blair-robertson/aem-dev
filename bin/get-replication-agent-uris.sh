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
# Returns the list of URIs for the Durbo replication agents on an AEM instance
#  
# 
# Usage:
#    $ get-replication-agent-uris.sh <aem url> <user> <aem type>
#    $ get-replication-agent-uris.sh http://localhost:4502 admin:admin
#    $ get-replication-agent-uris.sh http://localhost:4502 admin:admin author

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"
AEM_TYPE="${3:-author}"

curl -s -S -f -G -u "$AEM_USER" "$AEM_HOST/bin/querybuilder.json" \
  -d "path=/etc/replication/agents.${AEM_TYPE}" \
  -d "1_property=sling:resourceType" \
  -d "1_property.value=cq/replication/components/agent" \
  -d "2_property=enabled" \
  -d "2_property.value=true" \
  -d "3_property=serializationType" \
  -d "3_property.value=durbo" \
  -d "p.hits=full" \
  -d "p.limit=-1" \
  | jq -r '.hits[] | .transportUri' | dos2unix | perl -pe 's!^(https?://[^/]+).*$!$1!'

  
  