#!/bin/bash
# Fetch web logs and push to matomo

MTOKEN="1234567890ABCDEFG"
MYUSER="myuser"
MYNAME=$(basename -s .sh ${0})
DAILY=$(date +'%Y%m%d')
TIME=$(date +'%H%M%S')
WORKDIR="/opt/weblogs"
LOGDIR=${WORKDIR}/log
LOGFILE=${LOGDIR}/${MYNAME}-${DAILY}.log
LOGENTRY="${DAILY} ${TIME} :"
WEBLOGS="/var/log/nginx/"
IDSITE="1"
MATOMO_DIR="/home/${MYUSER}/matomo-import"
MATOMO="${MATOMO_DIR}/import_logs.py"
MATOMO_URL="https://matomo.example.com"

function help_me () {
  echo "usage ${MYNAME} <web server> <domain> <matomo idsite>"
  echo "\n"
  echo "**** Additional parameters will be ignored ****"
}
function logme () {
  if [ ! -d ${LOGDIR} ]; then
    script_err "Log directory not found. Exiting."

  fi

  if [ -z "${1}" ]; then
    echo "${LOGENTRY} --------- " >> ${LOGFILE}
  else
    echo "${LOGENTRY} ${1}" >> ${LOGFILE}
  fi

}
function push_logs () {
logme "--------- Starting import"
# options which I've left out: --enable-bots --enable-http-errors
python3 ${MATOMO} --token-auth=${MTOKEN} --url=${MATOMO_URL} --enable-static --enable-reverse-dns --recorders=4 --idsite=${IDSITE} ${WORKDIR}/${DOMAIN}/access.log.1 >> ${LOGFILE}
logme "--------- Import finished"
}
function script_err () {
  if [ -z "${1}" ]; then
    echo "Unknown error. Exiting" >&2
    exit 1
  else
    echo "Experienced the following error: "
    echo ${1} >&2
    exit 1
  fi
}
function sync_logs () {
logme "starting sync from ${WEB_SERVER} for ${DOMAIN}"
rsync -a ${MYUSER}@${WEB_SERVER}:${WEBLOGS} ${WORKDIR}/${DOMAIN}/
}

function check_args () {
  if [ -z "${1}" ]; then
    help_me
    script_err "No arguments received"
  fi
  case ${1} in
    help)
      help_me
      exit 0
    ;;
    *)
      if [[ $# -lt 3 ]]; then
        help_me
        script_err "Not enough arguments, need exactly 3"
      fi
      WEB_SERVER=${1}
      DOMAIN=${2}
      IDSITE=${3}
      sync_logs
      push_logs
    ;;
  esac
}
# $1= server $2= domain $3= matomo site id.
check_args $@
exit 0
