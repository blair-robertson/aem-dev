#!/bin/bash
########################################################################################
# MIT License                                                                          #
#                                                                                      #
# Copyright (c) Blair Robertson 2022                                                   #
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
#  Outputs a list of AEM Groups that a user is a Direct member
# 
# Usage:
#    $ get-user-memberships.sh <aem url> <user> <user path>
#    $ get-user-memberships.sh http://localhost:4502 admin:admin
#    $ get-user-memberships.sh http://localhost:4502 admin:admin /home/users/O/OIkFTmQdLMQkpcYQtZWR

set -ue

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin:admin}"
USER_PATH="${3:-/home/users/missing}"

# set -x
curl -sSf -G -u "${AEM_USER}" \
  "${AEM_HOST}${USER_PATH}.rw.json" \
  -d 'props=declaredMemberOf' \
  | jq -r '.declaredMemberOf[] | .authorizableId' | dos2unix
