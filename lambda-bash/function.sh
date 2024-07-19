function handler () {
  EVENT_DATA=$1
  RESPONSE="RESULT: "
  LINES=0
  FOUND=0
  cd /tmp
  NEWFILE=$(echo $EVENT_DATA | sed 's/\\//g' | jq ".Records[0].s3.object.key"| tr -d '"')

  aws s3 cp s3://$NEWFILE .
  FILENAME="$(basename $NEWFILE)"
  TYPE=$(file -b ${FILENAME} | awk '{ print $1}')
  if [ $TYPE == "gzip" ]; then
    LINES=$(zgrep -v '^#' $FILENAME | wc -l $FILENAME)
    FOUND=$(zgrep -c 'rock the whole globe')
    if [ $FOUND == 0 ]; then
      RESPONSE="I searched ${LINES} lines and the file does not contain the string. That bad-bad"
    else
      RESPONSE="I searched ${LINES} lines and the file contains the string "${FOUND}" times. That good-good"
    fi

  else if [ $TYPE == "ASCII" ]; then
    LINES=$(grep -v '^#' $FILENAME | wc -l $FILENAME)
    FOUND=$(grep -c 'rock the whole globe')
    if [ $FOUND == 0 ]; then
      RESPONSE="I searched ${LINES} lines and the file does not contain the string. That bad-bad"
    else
      RESPONSE="I searched ${LINES} lines and the file contains the string "${FOUND}" times. That good-good"
    fi
  else
    RESPONSE="ERROR: Unknown file type"
  fi








  echo $RESPONSE
}