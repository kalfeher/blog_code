#!/bin/bash


## Globals
MYNAME=$(basename -s .sh ${0})
if [[ "$(uname)" == "Darwin" ]]; then
    # We're on a Mac
    start=$(date -v -1d '+%Y-%m-%dT00:00:00Z')
else 
    # We're on Linux
    start=$(date --date="-1 day" '+%Y-%m-%dT00:00:00Z')
fi

## AWS CLI Settings
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
AWS_PATH=/usr/local/bin/aws
## JQ Settings
JQ_PATH=/opt/local/bin/jq


## Functions
function help_me () {
	echo "Find an expiring certificate using its serial"
	#### Usage syntax
	echo "usage ${MYNAME} <serial>"
	#### Usage details
	echo "Serial value must be an Integer or Hexadecimal value"
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
function check_deps () {
	# Check for dependencies
	DEPS=( ${AWS_PATH} ${JQ_PATH} )
	MISSING=()
		for DEP in "${DEPS[@]}"; do
			if [ ! -f ${DEP} ]; then
				MISSING+=(${DEP})
			fi
		done
		if [ ${#MISSING[@]} -gt 0 ]; then
			for MISSING_DEP in "${MISSING[@]}"; do
				echo "Missing dependency: ${MISSING_DEP}"
			done
			script_err "Install dependancies or update paths in script"
		fi
}
function check_args () {
	#Do something with arguments
	if [ -z "${1}" ]; then
		help_me
		script_err "No script arguments received"
	fi
	case ${1} in
		help)
			help_me
			exit 0
		;;
		*)
			if [[ ${1} =~ ^[0-9]+$ ]]; then
                (( 10#${1} ))
                if [ $? -ne 0 ]; then
                    script_err "Input does not appear to be integer"
				else
					serial=${1}
                fi
            else
                (( 16#${1} ))
                if [ $? -ne 0 ]; then
                    script_err "Input does not appear to be integer or hex value"
				else
					serial=${1}
                fi
            fi


		;;
	esac
}
## MAIN
check_args $@
check_deps
## Fetch unique CNs for serial
echo "Searching for Certificates with serial:${serial} in CloudTrail from ${start} until now"
${AWS_PATH} cloudtrail lookup-events --start-time ${start} --lookup-attributes AttributeKey=EventSource,AttributeValue=rolesanywhere.amazonaws.com | ${JQ_PATH} '.Events[].CloudTrailEvent' | grep ${serial} | egrep -o 'CN=([a-z0-9.-])*'|uniq

# vim: set ts=2 expandtab sw=2 smarttab :
