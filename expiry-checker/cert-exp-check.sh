#!/bin/bash
# Stand alone certificate expiry checker
WEBSITE=$1
DAYS=$2
NOW=$(date +%s)
function checkdays ()
{
        if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
                echo "Please provide a number of days to check"
                exit 1
        fi 2>/dev/null
        if [ "$DAYS" -lt 1 ]; then
                echo "Please provide a number of days to check. Number must be 1 or more"
                exit 1
        fi
}

function checkwebsite ()
{
        if ! [[ "$WEBSITE" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                echo "Please provide a valid website to check"
                exit 1
        fi 2>/dev/null
        if ! [[ "$WEBSITE" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "Please provide a valid website to check"
                exit 1
        fi 2>/dev/null
}
function checkexpiry ()
{
  EXPIRY=$(openssl s_client -servername ${WEBSITE} -connect ${WEBSITE}:443 </dev/null 2> /dev/null| openssl x509 -enddate -noout | cut -d= -f2)
  # MacOs date conversion
  UXEXPIRY=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s)
  # Linux date conversion 
  #UXEXPIRY=$(date -d "$EXPIRY" +%s)
  WILLEXP=$(openssl s_client -servername ${WEBSITE} -connect ${WEBSITE}:443 </dev/null 2> /dev/null| openssl x509 -checkend ${EXP} -noout)

  if [[ $WILLEXP == *"will expire"* ]]; then
          echo "ALERT|${WEBSITE}|${EXPIRY}|${UXEXPIRY}"
          exit 1
  else
          echo "OK|${WEBSITE}|${EXPIRY}|${UXEXPIRY}"
          exit 0
  fi

}

if [ -z "$WEBSITE" ]; then
        echo "Please provide a website to check"
        exit 1
else
        checkwebsite
fi

if [ -z "$DAYS" ]; then
        echo "Please provide a number of days to check"
        exit 1
else
        checkdays
        EXP=$(( 86400 * $DAYS ))
fi
checkexpiry  


