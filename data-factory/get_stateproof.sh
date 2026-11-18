TXID=`curl "https://mainnet-idx.4160.nodely.dev/v2/accounts/XM6FEYVJ2XDU2IBH4OT6VZGW75YM63CM4TC6AV6BD3JZXFJUIICYTVB5EU/transactions?limit=1" | jq -r ".transactions[0].id"`

curl https://mainnet-api.4160.nodely.dev/v2/transactions/pending/$TXID | jq .txn > stateproof.json
echo "Transaction ID: $TXID"
