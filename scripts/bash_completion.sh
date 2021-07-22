#!/bin/bash

function check_path() {
	if [ "$1" == "file" ]; then if [ -f "$2" ]; then return; fi; fi
	if [ "$1" == "directory" ]; then if [ -d "$2" ]; then return; fi; fi

	echo "Error: $1 $2 not found"
	echo "       make sure to call the script from the root of the teeworlds code"
	exit 1
}

check_path file ./other/bash-completion/teeworlds_srv
check_path file ./other/bash-completion/teeworlds
check_path directory ./src/

function tw_configs() {
	local flag="$1"
	local line
	grep -r "MACRO_CONFIG_.*CFGFLAG_$flag" src/ --include={variables.h,config_variables.h} | LC_ALL=C sort | while IFS= read -r line
	do
		line="$(echo "$line" | cut -d'(' -f2 | cut -d',' -f2)"
		printf '%s ' "${line:1}"
	done
}

function tw_commands() {
	local flag="$1"
	local line
	grep -roh "Register(\".*CFGFLAG_$flag" src/ | LC_ALL=C sort | while IFS= read -r line
	do
		line="$(echo "$line" | cut -d'(' -f2 | cut -d'"' -f2)"
		printf '%s ' "$line"
	done
}

function tw_update_server() {
	local cfgs
	local cmds
	local comp_helper
	cfgs="$(tw_configs SERVER)"
	cfgs="\"${cfgs::-1}\""
	cmds="$(tw_commands SERVER)"
	cmds="\"${cmds::-1}\""

	read -r -d '' comp_helper <<-EOF
	# generated start
	# DO NOT EDIT THIS FUNCTION MANUALLY
	# GENERATED BY ./scripts/bash_completion.sh
	_teeworlds_srv_commands_helper() {
	\tlocal cur=\"\$1\"
	\tlocal configs=$cfgs
	\tlocal commands=$cmds
	\tCOMPREPLY+=(\$(compgen -W \"\$configs\" -- \"\$cur\"))
	\tCOMPREPLY+=(\$(compgen -W \"\$commands\" -- \"\$cur\"))
	}
	# generated end
	EOF
	# prepare newlines for sed
	comp_helper="$(echo "$comp_helper" | sed 's/$/\\n/' | tr -d '\n')"
	# cut off last newline to not add empty lines every time the script is run
	comp_helper="${comp_helper::-2}"

	sed -ie "/generated start/,/generated end/c\\$comp_helper" ./other/bash-completion/teeworlds_srv

	if [ -f /usr/share/bash-completion/completions/teeworlds_srv ]
	then
		cp ./other/bash-completion/teeworlds_srv /usr/share/bash-completion/completions/teeworlds_srv
	fi
}

function tw_update_client() {
	local cfgs
	local cmds
	local comp_helper
	cfgs="$(tw_configs CLIENT)"
	cfgs="\"${cfgs::-1}\""
	cmds="$(tw_commands CLIENT)"
	cmds="\"${cmds::-1}\""

	read -r -d '' comp_helper <<-EOF
	# generated start
	# DO NOT EDIT THIS FUNCTION MANUALLY
	# GENERATED BY ./scripts/bash_completion.sh
	_teeworlds_commands_helper() {
	\tlocal cur=\"\$1\"
	\tlocal configs=$cfgs
	\tlocal commands=$cmds
	\tCOMPREPLY+=(\$(compgen -W \"\$configs\" -- \"\$cur\"))
	\tCOMPREPLY+=(\$(compgen -W \"\$commands\" -- \"\$cur\"))
	}
	# generated end
	EOF
	# prepare newlines for sed
	comp_helper="$(echo "$comp_helper" | sed 's/$/\\n/' | tr -d '\n')"
	# cut off last newline to not add empty lines every time the script is run
	comp_helper="${comp_helper::-2}"

	sed -ie "/generated start/,/generated end/c\\$comp_helper" ./other/bash-completion/teeworlds

	if [ -f /usr/share/bash-completion/completions/teeworlds ]
	then
		cp ./other/bash-completion/teeworlds /usr/share/bash-completion/completions/teeworlds
	fi
}

tw_update_server
tw_update_client
