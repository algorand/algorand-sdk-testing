#!/usr/bin/env bash
#
# Queries the indexer SDK testing service and generates goldens.

rootdir=`dirname $0`
pushd $rootdir/../features/resources/v2indexerclient_responsejsons > /dev/null

curl "localhost:59998/v2/applications?application-id=22" > indexer_v2_app_search_22.json
curl "localhost:59998/v2/applications?limit=3"           > indexer_v2_app_search_limit_3.json
curl "localhost:59998/v2/applications?next=25&limit=1"   > indexer_v2_app_search_next_25.json
curl "localhost:59998/v2/applications?application-id=70" > indexer_v2_app_search_70.json

curl "localhost:59998/v2/applications/22"                > indexer_v2_app_lookup_22.json
curl "localhost:59998/v2/applications/70"                > indexer_v2_app_lookup_70.json

curl "localhost:59998/v2/transactions?application-id=70"         > indexer_v2_tx_search_app_70.json
curl "localhost:59998/v2/transactions?application-id=70&limit=3" > indexer_v2_tx_search_app_70_lim_3.json

curl "localhost:59998/v2/accounts?application-id=70"    > indexer_v2_acct_search_app_70.json
