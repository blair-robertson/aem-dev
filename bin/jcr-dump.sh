#!/bin/bash

set -ue

AEM_HOST="${1:-http://localhost:4502}"
AEM_USER="${2:-admin}"
AEM_PASSWORD="${3:-admin}"
AEM_PATH="${4:-/content/we-retail}"

set -x
curl -G -u "${AEM_USER}:${AEM_PASSWORD}" \
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
