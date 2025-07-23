#!/usr/bin/env bash

#	https://topmedimpute.readthedocs.io/en/latest/api/

#	https://imputationserver.readthedocs.io/en/latest/api/



name=""
server="topmed"
refpanel="apps@topmed-r3"
build="hg19"
r2Filter="0.3"
#pgscatalog="apps@pgs-catalog-20240318@1.0"
#traits="all"
#ancestry=""	#	"apps@ancestry@1.0.0"
#phasing="eagle"
population=all

files=""

while [ $# -gt 0 ] ; do
	case $1 in
		-s|--server)
			shift;server="${1}";shift;;
		-n|--job-name)
			shift;name="${1}";shift;;
		-r|--refpanel)
			shift;refpanel="${1}";shift;;
		-b|--build)
			shift;build="${1}";shift;;
#		-f|--filter|--rsq|--r2Filter)
#			shift;r2Filter="${1}";shift;;
#		-c|--catalog|--pgscatalog)
#			shift;pgscatalog="${1}";shift;;
#		-t|--traits)
#			shift;traits="${1}";shift;;
#		-a|--ancestry)
#			shift;ancestry="${1}";shift;;
		-*)
			echo "Unknown param :$1:"; exit;;
		*)
			files="${files} -F \"files=@${1}\""; shift;;
	esac
done

if [ -z "${name}" ] ; then
	echo "Name is required"
	exit
fi

if [ "${server}" == "topmed" ] ; then
	TOKEN=$( cat TOPMED_TOKEN )
	command="curl https://imputation.biodatacatalyst.nhlbi.nih.gov/api/v2/jobs/submit/imputationserver -H \"X-Auth-Token: $TOKEN\""
elif [ "${server}" == "umich" ] ; then
	TOKEN=$( cat UMICH_TOKEN )
	command="curl https://imputationserver.sph.umich.edu/api/v2/jobs/submit/imputationserver2 -H \"X-Auth-Token: $TOKEN\""
else
	echo "Unknown server :${server}:"
	exit
fi



#command="${command} -F \"job-name=${name}\" -F \"refpanel=${refpanel}\" -F \"build=${build}\" -F \"r2Filter=${r2Filter}\" ${files}"
command="${command} -F \"job-name=${name}\" -F \"refpanel=${refpanel}\" -F \"build=${build}\" -F \"r2Filter=${r2Filter}\" -F \"population=${population}\" ${files}"


#if [ -n "${ancestry}" ] ; then
#	command="${command} -F \"ancestry=${ancestry}\""
#fi

#	https://genepi.github.io/michigan-imputationserver/tutorials/api/


#curl -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs

#echo "${command}${params}${files}"
echo "${command}"


#	refpanel
#	<option value="apps@1000g-phase-1@2.0.0"> 1000G Phase 1 v3 Shapeit2 (no singletons) (GRCh37/hg19) </option>
#	<option value="apps@1000g-phase3-low@1.0.0"> 1000G Phase 3 (GRCh38/hg38) [BETA] </option>
#	<option value="apps@1000g-phase3-deep@1.0.0"> 1000G Phase 3 30x (GRCh38/hg38) [BETA] </option>
#	<option value="apps@1000g-phase-3-v5@2.0.0"> 1000G Phase 3 v5 (GRCh37/hg19) </option>
#	<option value="apps@caapa@2.0.0"> CAAPA African American Panel (GRCh37/hg19) </option>
#	<option value="apps@genome-asia-panel@1.0.0"> Genome Asia Pilot - GAsP (GRCh37/hg19) </option>
#	<option value="apps@hrc-r1.1@2.0.0"> HRC r1.1 2016 (GRCh37/hg19) </option>
#	<option value="apps@hapmap-2@2.0.0"> HapMap 2 (GRCh37/hg19) </option>
#	<option value="apps@samoan@2.0.0"> Samoan (GRCh37/hg19) </option>


