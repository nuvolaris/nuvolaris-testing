#!/bin/bash

#ID=Z09449781AEA79H161VH6
#DOMAIN=eks.nuvtest.net.
#ID=${1:?zone id}

#DOMAIN=${2:?domain}
#TYPE=${3:?type}
#VALUE=${4:?value}

TYPE="${1:?test type}"
TYPE="$(echo $TYPE | awk -F- '{print $1}')"
VALUE="${2:?ip or cname}"
REC="${3:-A}"
DOMAIN="$TYPE.nuvtest.net"

case $TYPE in
k3s) ID=Z0096994K8S6KL0FF6TL ;;
mk8s) ID=Z04984831L1U032GQ1YSR ;;
eks) ID=Z09449781AEA79H161VH6 ;;
aks) ID=Z0092660FFL09OQKKQWR ;;
gke) ID=Z04927103UQGCZORDWZM6 ;;
esac

cat <<EOF >_update.json
{
  "Comment": "Update $REC record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "*.$DOMAIN",
        "Type": "$REC",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$VALUE"
          }
        ]
      }
    }
  ]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id=$ID --change-batch file://_update.json

# waiting for DNS
echo "*** waiting for the dns to to be ready"
N=0
while true; do
  if host -a api.$DOMAIN | grep $VALUE; then
    break
  else
    echo $((N++)) waiting DNS
    sleep 5
  fi
done
