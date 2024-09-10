function handler () {
  EVENT_DATA=$1
  RESPONSE="RESULT: "
  LINES=0
  FOUND=0
  cd /tmp
  NEWFILE=$(echo $EVENT_DATA | sed 's/\\//g' | jq ".Records[0].s3.object.key"| tr -d '"')
  aws s3 cp s3://$NEWFILE .
  FILENAME="$(basename $NEWFILE)"
  # Do something with the file

  # What is the file type?
  TYPE=$(file -b ${FILENAME} | awk '{ print $1}')
  # search for the string in the file based on the type of file.
  if [ $TYPE == "gzip" ]; then
    LINES=$(zgrep -v '^#' $FILENAME | wc -l $FILENAME)
    FOUND=$(zgrep -c 'rock the whole globe')
    if [ $FOUND == 0 ]; then
      RESPONSE=${RESPONSE}"I searched ${LINES} lines and the file does not contain the string."
    else
      RESPONSE=${RESPONSE}"I searched ${LINES} lines and the file contains the string "${FOUND}" times."
    fi

  else if [ $TYPE == "ASCII" ]; then
    LINES=$(grep -v '^#' $FILENAME | wc -l $FILENAME)
    FOUND=$(grep -c 'rock the whole globe')
    if [ $FOUND == 0 ]; then
      RESPONSE=${RESPONSE}"I searched ${LINES} lines and the file does not contain the string."
    else
      RESPONSE=${RESPONSE}"I searched ${LINES} lines and the file contains the string "${FOUND}" times."
    fi
  else
    RESPONSE=${RESPONSE}"ERROR Unknown file type"
  fi
  # echo the result of our function
  echo $RESPONSE
}