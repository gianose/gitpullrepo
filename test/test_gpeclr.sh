#!/usr/bin/env bash
# Author: Gregory Rose
# Createdi: 20170410
# Name: test_gpeclr.sh
# Relative Working Directory: ${NAMESPACE}/test/test_gpeclr.sh

declare TST_GPECLR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. ${TST_GPECLR_DIR}/../lib/const.sh
. ${NAMESPACE}lib/unittest.sh
. ${NAMESPACE}lib/excp.sh 

################################################################################
# In order utilize `test_gpeclr.sh` to properly test `gpeclr` please follow    #
# the instruction provided here '' in order to add your ssh key to gitlab      #
# and to create a test repository. Following that set 'TST_GPECLR_SSH_REPO'    #
# to the ssh URL of your test repo, and 'TST_GPECLR_REPO' to the http URL of   #
# your test repo                                                               #
################################################################################

declare TST_GPECLR_REPO='https://gitlab.ins.risk.regn.net/RoseGr01/tst_gpeclr.git'
declare TST_GPECLR_SSH_REPO='git@gitlab.ins.risk.regn.net:RoseGr01/tst_gpeclr.git'

#################################################################################
# Futhermore please set the following variable 'TST_GPECLR_CONTACT' to your     #
# email address.                                                                #
#################################################################################

declare TST_GPECLR_CONTACT='gregory.rose@lexisnexis.com'

#################################################################################

declare TST_GPECLR="${NAMESPACE}bin/gpeclr"
declare TST_GPECLR_BAD_REPO='https://gitlab.ins.risk.regn.net/FakeUser01/NotReal.git'
declare TST_GPECLR_BRANCH='master'
declare TST_GPECLR_BAD_BRANCH='foo'
declare TST_GPECLR_USAGE_OUT="${NAMESPACE}tmp/tst_gpeclr_usage.out"
declare TST_GPECLR_CONFIG="${NAMESPACE}config/gpeclr.cnf"
declare TST_GPECLR_CONFIG_BACKUP="${TST_GPECLR_CONFIG}.backup"
declare TST_GPECLR_DEST="${NAMESPACE}tmp/good"
declare TST_GPECLR_REPO_DEST="${NAMESPACE}tmp/repo"
declare TST_GPECLR_BAD_CLONE_DEST="${NAMESPACE}tmp/bad_clone"
declare TST_GPECLR_BAD_PULL_DEST="${NAMESPACE}tmp/bad_pull"

$TST_GPECLR > ${TST_GPECLR_USAGE_OUT}

declare TST_GPECLR_USAGE_MD5=$(md5sum ${TST_GPECLR_USAGE_OUT} | awk '{print $1}')

declare -a TST_GPECLR_PUT_USAGE=(
	"gpeclr::${TST_GPECLR} - Zero input params;0;"
	"gpeclr::${TST_GPECLR} - Just the repo;0;-r;${TST_GPECLR_REPO}"
	"gpeclr::${TST_GPECLR} - Just the repo and the branch;0;-r;${TST_GPECLR_REPO};-b;${TST_GPECLR_BRANCH}"
	"gpeclr::${TST_GPECLR} - Just the log directory;0;-l;${NAMESPACE}logs"
	"gpeclr::${TST_GPECLR} - '-C' option followed by a additional param;0;-C;foo"
	"gpeclr::${TST_GPECLR} - '-h' option followed by a additional param;0;-h;bar"	
)

declare -a TST_GPECLR_THROW_ERR=(
	"gpeclr::${TST_GPECLR} - The destination option (-d) with no directory following;113;-d"
	"gpeclr::${TST_GPECLR} - The log option (-l) with no directory following;113;-l"
	"gpeclr::${TST_GPECLR} - The repository option (-r) with no url following;113;-r"
	"gpeclr::${TST_GPECLR} - The branch option (-b) with no branch following;113;-b"
	"gpeclr::${TST_GPECLR} - The destination option (-d) with a non existant destination;113;-d;/not/real/dir"
	"gpeclr::${TST_GPECLR} - The log option (-l) with a non existant log directory;113;-l;/not/real/dir"
	"gpeclr::${TST_GPECLR} - The repo option (-r) with a non existant url;113;-r;${TST_GPECLR_BAD_REPO}"
	"gepclr::${TST_GPECLR} - The branch option (-b) without the a corresponding repo;113;-r;${TST_GPECLR_BAD_BRANCH}"
	"gpeclr::${TST_GPECLR} - The branch option (-b) with a non existant branch;113;-r;${TST_GPECLR_REPO};-b;${TST_GPECLR_BAD_BRANCH}"
)

declare -a TST_GPECLR_FATAL_ERR=(
	"gpeclr::${TST_GPECLR} - The config option (-C) with gpeclr.cnf missing;107;-C"
	"gpeclr::${TST_GPECLR} - The destination option (-d) with a valid destination, but gpeclr.cnf missing;107;-d ${TST_GPECLR_DEST}"
	"gpeclr::${TST_GPECLR} - Attempt to clone to non-empty destination dir;107;-d ${TST_GPECLR_BAD_CLONE_DEST} -r ${TST_GPECLR_REPO}"
	"gpeclr::${TST_GPECLR} - Attempt to pull to inaccessible local repo;107;-d ${TST_GPECLR_BAD_PULL_DEST} -r ${TST_GPECLR_REPO}"
)

tst_gpeclr_neg() {
	#printf "%s\n" "USAGE"
	#runCustom TST_GPECLR_PUT_USAGE[@] tst_gpeclr_put_usage
	#printf "%s\n" "ERROR InvalidArgument"
	#runMultiInput TST_GPECLR_THROW_ERR[@]
	#printf "%s\n" "CORRECT"
	tst_gpeclr_prep
	#printf "%s\n" "ERROR FatalError"
	#runMultiInput TST_GPECLR_FATAL_ERR[@]
	#tst_gpeclr_clean
	#printf "%s\n" "CONFIG ERROR InvalidArgument"
	#tst_gpeclr_cnf_arg_err
}

tst_gpeclr_put_usage() {
	declare -a params=("${!1}")
	
	local _f=${params[0]%% - *}; _f=${_f##*::}
	[ -s ${TST_GPECLR_USAGE_OUT} ] && truncate -s 0 ${TST_GPECLR_USAGE_OUT} 
	
	case ${#params[@]} in
		2) $($_f &> ${TST_GPECLR_USAGE_OUT})
			;;
		3) $($_f ${params[2]} &> ${TST_GPECLR_USAGE_OUT})
			;;
		4) $($_f ${params[2]} ${params[3]} &> ${TST_GPECLR_USAGE_OUT})
			;;
		5) $($_f ${params[2]} ${params[3]} ${params[4]} &> ${TST_GPECLR_USAGE_OUT})
			;;
		6) $($_f ${params[2]} ${params[3]} ${params[4]} ${params[5]} &> ${TST_GPECLR_USAGE_OUT})
			;;
	esac
	
	local _md5=$(md5sum ${TST_GPECLR_USAGE_OUT} | awk '{print $1}')
	[ ${_md5} == ${TST_GPECLR_USAGE_MD5} ] && return ${?}
	return 1
}

tst_gpeclr_prep() {
	_bad_clone_dest() {
		[ -d "${TST_GPECLR_BAD_CLONE_DEST}" ] || { 
			mkdir "${TST_GPECLR_BAD_CLONE_DEST}"
			touch "${TST_GPECLR_BAD_CLONE_DEST}/tst_gpeclr.txt"
		}
	}
	
	case "${FUNCNAME[1]}" in
		'tst_gpeclr_neg' ) 
			[ -s ${TST_GPECLR_CONFIG} ] && mv "${TST_GPECLR_CONFIG}" "${TST_GPECLR_CONFIG_BACKUP}"
			_bad_clone_dest

			[ -d "${TST_GPECLR_BAD_PULL_DEST}" ] || {
				mkdir ${TST_GPECLR_BAD_PULL_DEST}
				${TST_GPECLR} -d ${TST_GPECLR_BAD_PULL_DEST} -r ${TST_GPECLR_REPO}
				chmod -w ${TST_GPECLR_BAD_PULL_DEST}
				sleep .2		
			}

			[ -d "${TST_GPECLR_DEST}" ] || {
				mkdir "${TST_GPECLR_DEST}"
				${TST_GPECLR} -d ${TST_GPECLR_DEST} -r ${TST_GPECLR_REPO}
				assertEquals "gpeclr::${TST_GPECLR} - Cloning the repo '${TST_GPECLR_REPO}' to '${TST_GPECLR_DEST}'" 0 ${?}
				sleep .2
			}

			tst_gpeclr_alt_repo
			${TST_GPECLR} -d ${TST_GPECLR_DEST} -r ${TST_GPECLR_REPO}
			assertEquals "gpeclr::${TST_GPECLR} - Pull changes from repo '${TST_GPECLR_REPO}' to '${TST_GPECLR_DEST}'" 0 ${?}		
			;;
	esac
}

tst_gpeclr_alt_repo() {
	local _dir
	[ -d "${TST_GPECLR_REPO_DEST}" ] || {
		mkdir "${TST_GPECLR_REPO_DEST}" 
		${TST_GPECLR} -r ${TST_GPECLR_SSH_REPO} -d ${TST_GPECLR_REPO_DEST} && { 
			echo "#### Changed" >> "${TST_GPECLR_REPO_DEST}/README.md"
			[[ ${TST_GPECLR_REPO_DEST:$((${#TST_GPECLR_REPO_DEST}-1))} == "/" ]] && _dir=${TST_GPECLR_REPO_DEST}'.git' || _dir=${TST_GPECLR_REPO_DEST}'/.git'
			git --git-dir=${_dir} --work-tree=${TST_GPECLR_REPO_DEST} add ${TST_GPECLR_REPO_DEST}/README.md
			git --git-dir=${_dir} --work-tree=${TST_GPECLR_REPO_DEST} commit -m 'Maked Change to README.md' --quiet
			git --git-dir=${_dir} --work-tree=${TST_GPECLR_REPO_DEST} push origin master --quiet 
		}
	}
}

tst_gpeclr_clean() {
	case "${FUNCNAME[1]}" in
		'tst_gpeclr_neg' )
			[ -s "${TST_GPECLR_USAGE_OUT}" ] && rm "${TST_GPECLR_USAGE_OUT}"
			[ -s "${TST_GPECLR_CONFIG_BACKUP}" ] && mv "${TST_GPECLR_CONFIG_BACKUP}" "${TST_GPECLR_CONFIG}"
			[ -d "${TST_GPECLR_BAD_CLONE_DEST}" ] && rm -rf "${TST_GPECLR_BAD_CLONE_DEST}"
			[ -d "${TST_GPECLR_BAD_PULL_DEST}" ] && {
				chmod +w ${TST_GPECLR_BAD_PULL_DEST}
				rm -rf ${TST_GPECLR_BAD_PULL_DEST}
			}
			[ -d "${TST_GPECLR_DEST}" ] && rm -rf "${TST_GPECLR_DEST}"
			[ -d "${TST_GPECLR_REPO_DEST}" ] && rm -rf "${TST_GPECLR_REPO_DEST}"
			;;
	esac
}

tst_gpeclr_cnf_arg_err() {
	declare -a _original
	
	local _cnf=$(cat ${TST_GPECLR_CONFIG} | grep -P -i '^\w+:' | tr '\r\n' '|') 
	IFS='|' read -r -a _original <<< ${_cnf}

	declare -a _bad_params=(
		"^contact:.*;contact: ${TST_GPECLR_CONTACT}"
		"^logs:.*;logs: /not/real/log/dir;gpeclr::${TST_GPECLR} - The directory for logs set in config/gpeclr.cnf is nonexistent."
		"^destination:.*;destination: /not/rea/dest/dir;gpeclr::${TST_GPECLR} - The directory for destination set in config/gpeclr.cnf is nonexistent."
		"^repository:.*;repository: ${TST_GPECLR_BAD_REPO}/;gpeclr::${TST_GPECLR} - The URL provided for the repo in config/gpeclr.cnf is incorrect."
		"^branch:.*;branch: foo;gpeclr::${TST_GPECLR} - The branch provided for the repo in config/gpeclr.cnf is incorrect."
	)

	for i in "${!_bad_params[@]}"; do
		declare -a _params
		IFS=';' read -r -a _params <<< ${_bad_params[$i]}
		
		sed -ie "s~${_params[0]}~${_params[1]}~" "${TST_GPECLR_CONFIG}"

		[ ${i} -eq 0 ] && { _regex=${_params[0]}; _contact=${_params[1]}; continue; }	

		${TST_GPECLR} -C
		assertEquals "${_params[2]}" 113 ${?}
		
		sleep .2
		
		sed -ie "s~${_params[0]}~${_original[${i}]}~" ${TST_GPECLR_CONFIG}
	done

	sed -ie "s~${_regex}~${_contact}~" ${TST_GPECLR_CONFIG}
}

tst_gpeclr_cnf_ftl_err() {
	declare -a _original
	
	# Backup the original configuration file.	
	local _cnf=$(cat ${TST_GPECLR_CONFIG} | grep -P -i '^\w+:' | tr '\r\n' '|') 
	IFS='|' read -r -a _original <<< ${_cnf}
	
	# Replace the repo currently in the config file with the test repo.
	sed -ie "s~^repository:.*~repository: ${TST_GPECLR_REPO}~" ${TST_GPECLR_CONFIG}
	
	
	declare -a _cnf_cor=(
		"gpeclr::${TST_GPECLR} - Cloning the repo '${TST_GPECLR_REPO}' to '${TST_GPECLR_DEST}';0;${TST_GPECLR_DEST}"
	)

	# Replace the repo in the config file with the orginal repo.
	sed -ie "s~^repository:.*~${_original[3]}~" ${TST_GPECLR_CONFIG}
}

tst_gpeclr_cnf_work() {
	declare -a _params
	IFS=';' read -r -a _params <<< ${1}

	[ -d "${_params[2]}" ] || mkdir "${_params[2]}"
	sed -ie "s~^destination:.*~destination: ${_params[2]}~" ${TST_GPECLR_CONFIG}
	
	[ ${_params[3]} ] && $_params[3] 
	
	${TST_GPECLR} -C
	
	assertEquals "${_params[0]}" ${_params[1]} ${?}
	
	sed -ie "s~^destination:.*~destination: ${_original[2]}~" ${TST_GPECLR_CONFIG}
}

# 1. unless TST_GPECLR_REPO_DEST exist, make DIR TST_GPECLR_REPO_DEST
# 2. Call tst_gpeclr_alt_repo with TST_GPECLR_REPO_DEST
# 3. 
#tst_gpeclr_neg
tst_gpeclr_cnf_ftl_err
