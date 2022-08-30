#!/bin/bash
## Globals
MYNAME=$(basename -s .sh ${0})
DAILY=$(date +'%Y%m%d')
TIME=$(date +'%H%M%S')
WORKDIR="/etc/certificates/"
CERT_DIR=${WORKDIR}/certificates
CONF=${WORKDIR}/conf/config.json
LOGDIR=${WORKDIR}/log
LOGFILE=${LOGDIR}/${MYNAME}-${DAILY}.log
LOGENTRY="${DAILY} ${TIME} :"
ISSUER="issuer-ca"
ISSUE_D=${WORKDIR}/issuer
HOST="myhost"
PROFILE="host"



## Functions
function help_me () {
	echo "Script used to generate certificate for a host"
	#### Usage syntax
	echo "usage ${MYNAME} <hostname>"
	#### Usage details
	echo "A file of <hostname>.json must be present in the ${CERT_DIR} directory"
}
function logme () {
	if [ ! -d ${LOGDIR} ]; then
		script_err "Log directory not found. Exiting."

	fi

	if [ -z "${1}" ]; then
		echo "${LOGENTRY}Nothing to log" >> ${LOGFILE}
	else
		echo "${LOGENTRY} ${1}" >> ${LOGFILE}
	fi

}

function script_err () {
	# Something went wrong and we are exiting
	if [ -z "${1}" ]; then
		echo "Unknown error. Exiting"
		exit 1
	else
		echo "Experienced the following error: "
		echo ${1}
		exit 1
	fi
}
function check_args () {
	if [ -z "${1}" ]; then
		help_me
		script_err "No script arguments received"
	fi
	case ${1} in
		help)
			help_me
			exit 0
		;;

	esac
}

function signhost () {
  # We search for the file 'hostname'.json
  hostconf=${CERT_DIR}/${HOST}.json
  if [ ! -f ${hostconf} ]; then
    logme "${hostconf} not found"
    script_err "${hostconf} not found"
  fi
  cfssl gencert \
  -ca ${ISSUE_D}/${ISSUER}.pem \
  -ca-key ${ISSUE_D}/${ISSUER}-key.pem \
  -config ${CONF} \
  -profile ${PROFILE} \
  ${hostconf} \
| cfssljson -bare ${CERT_DIR}/${HOST}
}
## MAIN
check_args $@
signhost