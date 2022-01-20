#!/usr/bin/env bash
#
# Queries the indexer SDK testing service and generates goldens.

rootdir=`dirname $0`
mkdir -p $rootdir/../features/resources/v23x_indexerclient_responsejsons
pushd $rootdir/../features/resources/v23x_indexerclient_responsejsons > /dev/null

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?application-id=22" > indexer_v2_app_search_22.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?limit=3"           > indexer_v2_app_search_limit_3.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?next=25&limit=1"   > indexer_v2_app_search_next_25.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?application-id=70" > indexer_v2_app_search_70.json

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications/22"                > indexer_v2_app_lookup_22.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications/70"                > indexer_v2_app_lookup_70.json

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/transactions?application-id=70"         > indexer_v2_tx_search_app_70.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/transactions?application-id=70&limit=3" > indexer_v2_tx_search_app_70_lim_3.json

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/accounts?application-id=70"    > indexer_v2_acct_search_app_70.json

# Include deleted...
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?include-all=true&application-id=22" > indexer_v2_app_search_22_all.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?include-all=true&limit=3"           > indexer_v2_app_search_limit_3_all.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?include-all=true&next=25&limit=1"   > indexer_v2_app_search_next_25_all.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications?include-all=true&application-id=70" > indexer_v2_app_search_70_all.json

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications/22?include-all=true"                > indexer_v2_app_lookup_22_all.json
docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/applications/70?include-all=true"                > indexer_v2_app_lookup_70_all.json

docker run --network sdk-harness --rm curlimages/curl:7.81.0 "indexer-23x-2:8980/v2/accounts?include-all=true&application-id=70"    > indexer_v2_acct_search_app_70_all.json
