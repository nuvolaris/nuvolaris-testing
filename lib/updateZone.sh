#!/bin/bash

#ID=Z09449781AEA79H161VH6
#DOMAIN=eks.n9s.cc.
#ID=${1:?zone id}

#DOMAIN=${2:?domain}
#TYPE=${3:?type}
#VALUE=${4:?value}


TYPE="${1:?test type}"
TYPE="$(echo $TYPE | awk -F- '{print $1}')"
VALUE="${2:?ip or cname}"
DOMAIN="$TYPE.n9s.cc"

case $TYPE in 
(k3s) ID=Z0096994K8S6KL0FF6TL ; TYPE=A ;;
(mk8s) ID=Z04984831L1U032GQ1YSR ; TYPE=A ;;
(eks) ID=Z09449781AEA79H161VH6 ; TYPE=CNAME ;;
(aks) ID=Z0092660FFL09OQKKQWR ; TYPE=A ;;
(gke) ID=Z04927103UQGCZORDWZM6 ; TYPE=A ;;
esac

cat <<EOF >_update.json
{
  "Comment": "Update A record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "*.$DOMAIN",
        "Type": "$TYPE",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$VALUE"
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN",
        "Type": "$TYPE",
        "TTL": 30,
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
while true
do  if host -a $DOMAIN | grep $VALUE
    then break
    else echo $((N++)) waiting DNS ; sleep 5 
    fi
done
