function handler () {
  EVENT_DATA=$1
  SITES=$(echo $EVENT_DATA | sed 's/\\//g' | jq ".sites[]"| tr -d '"')
  DAYS=$(echo $EVENT_DATA | sed 's/\\//g' | jq ".days"| tr -d '"')
  SNSTOPIC=$(echo $EVENT_DATA | sed 's/\\//g' | jq ".snstopic"| tr -d '"')
  EXP=$(( 86400 * $DAYS ))
  NOW=$(date +%s)
  DEADLINE=$(( $NOW + $EXP ))
  MESSAGE=""
  while IFS= read -r site; do
    WEBSITE=$site
    EXPIRY=$(openssl s_client -servername ${WEBSITE} -connect ${WEBSITE}:443 </dev/null 2> /dev/null| openssl x509 -enddate -noout | cut -d= -f2)
    TSTAMP=$(date -d "$EXPIRY" +%s)
    if [ "$TSTAMP" -lt "$DEADLINE" ]; then
      RESPONSE="ALERT|${WEBSITE}|${EXPIRY}|${TSTAMP}"
      MESSAGE="${MESSAGE}${WEBSITE} Expires: ${EXPIRY} " 
    else
      RESPONSE="OK|${WEBSITE}|${EXPIRY}|${TSTAMP}"
    fi
    echo $RESPONSE 1>&2
  done <<< "$SITES"
if [ -z "$MESSAGE" ]; then
  RESULT="No Certificates Expiring"
else
  RESULT="Certificates Expiring: ${MESSAGE}"
aws sns publish \
  --topic-arn "${SNSTOPIC}" \
  --subject "ALERT | Expiring Certificates" \
  --message "Certificates for the following sites will expire in the next ${DAYS} days: ${MESSAGE}"
fi
  RESULT="${RESULT}- Check Completed: OK"
  echo $RESULT
}