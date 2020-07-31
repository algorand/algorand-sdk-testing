#!/usr/bin/env bash
#
# Create cucumber example tables for app transactions
#
# Must have an applications-enabled version of goal on the path, and any running node.
#
# hint: pipe output into 'column -t' to almost get the column alignmnet correct


# this is mandatory, 'goal app' currently only supports looking up fee/first-valid/last-valid
DATA_DIR="/home/will/algorand/networks/test/Node"
ACCOUNT_1=BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4
ACCOUNT_MNEMONIC="awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

NO_ACCOUNTS=
ONE_ACCOUNT="AAZFG7YLUHOQ73J7UR7TPJA634OIDL5GIEURTW2QXN7VBRI7BDZCVN6QTI"
TWO_ACCOUNTS="AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM"

# Parse arguments
OPTS=`getopt -o hd: --long help,data: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -d | --data) DATA_DIR="$2"; shift; shift ;;
    -h | --help) echo "Provide a data directory."; exit 0 ;;
    * ) break ;;
  esac
done

header() {
  echo "  | operation | application-id | sender | approval-prog-file | clear-prog-file | global-bytes | global-ints | local-bytes | local-ints | app-args | foreign-apps | foreign-assets | app-accounts | fee | first-valid | last-valid | genesis-hash | golden |"
}

app_row() {
  goal app $1 \
    --from "$2" \
    --app-id "$3" \
    --app-arg "$4" \
    --foreign-app "${5}" \
    --foreign-asset "${6}" \
    --app-account "${7}" \
    --fee "${8}" \
    --firstvalid "${9}" \
    --lastvalid "${10}" \
    --note "" \
    -o tmp.txn \
    -d "${DATA_DIR}"

  algokey sign -m "${ACCOUNT_MNEMONIC}" --txfile tmp.txn -o tmp.stxn
  GOLDEN=$(base64 -w 0 < tmp.stxn)
  rm tmp.txn tmp.stxn

  echo "  | $1        | $3             | $2     |                    |                 | 0            | 0           | 0           | 0          | $4       | $5           | $6           | $7  | $8          | $9         | ${10}  | genesis-hash-here | ${GOLDEN} |"

  unset GOLDEN
}

app_create_row() {
  goal app create \
    --creator "$1" \
    --approval-prog-raw "$2" \
    --clear-prog-raw "$3" \
    --global-byteslices "$4" \
    --global-ints "$5" \
    --local-byteslices "$6" \
    --local-ints "$7" \
    --app-arg "$8" \
    --foreign-app "${9}" \
    --foreign-asset "${10}" \
    --app-account "${11}" \
    --fee "${12}" \
    --firstvalid "${13}" \
    --lastvalid "${14}" \
    --note "" \
    -o tmp.txn \
    -d "${DATA_DIR}"

  algokey sign -m "${ACCOUNT_MNEMONIC}" --txfile tmp.txn -o tmp.stxn
  GOLDEN=$(base64 -w 0 < tmp.stxn)
  rm tmp.txn tmp.stxn

  echo " | create | 0 | $1 | $2 | $3 | $4 | $5 | $6 | $7 | $8 | $9 | ${10} | ${11} | ${12} | ${13} | ${14} | genesis-hash-here | ${GOLDEN} |"

  unset GOLDEN
}

app_update_row() {
  goal app update \
    --app-id "$1" \
    --from "$2" \
    --approval-prog-raw "$3" \
    --clear-prog-raw "$4" \
    --app-arg "$5" \
    --foreign-app "${6}" \
    --foreign-asset "${7}" \
    --app-account "${8}" \
    --fee "${9}" \
    --firstvalid "${10}" \
    --lastvalid "${11}" \
    --note "" \
    -o tmp.txn \
    -d "${DATA_DIR}"

  algokey sign -m "${ACCOUNT_MNEMONIC}" --txfile tmp.txn -o tmp.stxn
  GOLDEN=$(base64 -w 0 < tmp.stxn)
  rm tmp.txn tmp.stxn

  echo " | update | $1 | $2 | $3 | $4 | 0  | 0  | 0  | 0  | $5 | $6 | ${7} | ${8} | ${9} | ${10} | ${11} | genesis-hash-here | ${GOLDEN} |"

  unset GOLDEN
}

cd programs
goal clerk compile *teal > /dev/null
cd ..

echo "Examples:"
header

app_create_row "${ACCOUNT_1}" "programs/loccheck.teal.tok" "programs/one.teal.tok" 1 0 1 0 "str:test" 5555,6666 "" "$NO_ACCOUNT" 1234 9000 9010
app_create_row "${ACCOUNT_1}" "programs/zero.teal.tok" "programs/one.teal.tok" 1 0 1 0 "str:test" "" "" "$ONE_ACCOUNT" 1234 9000 9010

app_update_row 123 "${ACCOUNT_1}" "programs/one.teal.tok" "programs/zero.teal.tok" "str:test" 5555,6666 "" "$NO_ACCOUNT" 1234 9000 9010
app_update_row 456 "${ACCOUNT_1}" "programs/zero.teal.tok" "programs/loccheck.teal.tok" "str:test" "" "" "$ONE_ACCOUNT" 1234 9000 9010
app_update_row 456 "${ACCOUNT_1}" "programs/zero.teal.tok" "programs/loccheck.teal.tok" "str:test" 5555,6666 1000,2000 "$ONE_ACCOUNT" 1234 9000 9010
app_update_row 456 "${ACCOUNT_1}" "programs/zero.teal.tok" "programs/loccheck.teal.tok" "str:test" 5555,6666 3000 "$TWO_ACCOUNT" 1234 9000 9010

app_row call "${ACCOUNT_1}" 100 "str:test" 5555,6666 "" "$TWO_ACCOUNTS" 1234 9000 9010
app_row call "${ACCOUNT_1}" 100 "str:test" "" "" "$NO_ACCOUNTS" 1234 9000 9010
app_row call "${ACCOUNT_1}" 100 "str:test" 5555,6666 7777,8888 "$TWO_ACCOUNTS" 1234 9000 9010

app_row optin "${ACCOUNT_1}" 100 "str:test" 5555,6666 "" "$TWO_ACCOUNTS" 1234 9000 9010
app_row optin "${ACCOUNT_1}" 100 "str:test" "" "" "$NO_ACCOUNTS" 1234 9000 9010
app_row optin "${ACCOUNT_1}" 100 "str:test" 5555,6666 7777,8888 "$TWO_ACCOUNTS" 1234 9000 9010

app_row clear "${ACCOUNT_1}" 100 "str:test" 5555,6666 "" "$TWO_ACCOUNTS" 1234 9000 9010
app_row clear "${ACCOUNT_1}" 100 "str:test" "" "" "$NO_ACCOUNTS" 1234 9000 9010
app_row clear "${ACCOUNT_1}" 100 "str:test" 5555,6666 7777,8888 "$TWO_ACCOUNTS" 1234 9000 9010

app_row closeout "${ACCOUNT_1}" 100 "str:test" 5555,6666 "" "$TWO_ACCOUNTS" 1234 9000 9010
app_row closeout "${ACCOUNT_1}" 100 "str:test" "" "" "$NO_ACCOUNTS" 1234 9000 9010
app_row closeout "${ACCOUNT_1}" 100 "str:test" 5555,6666 7777,8888 "$TWO_ACCOUNTS" 1234 9000 9010

app_row delete "${ACCOUNT_1}" 100 "str:test" 5555,6666 "" "$TWO_ACCOUNTS" 1234 9000 9010
app_row delete "${ACCOUNT_1}" 100 "str:test" "" "" "$NO_ACCOUNTS" 1234 9000 9010
app_row delete "${ACCOUNT_1}" 100 "str:test" 5555,6666 7777,8888 "$TWO_ACCOUNTS" 1234 9000 9010
