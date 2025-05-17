# Grab creds from cba-deploy config files
admin_auth() {
    declare local dc
    [[ "$1" == "eng" ]] && dc=pdx || dc=dub
    local ta_pwd=$(sed -n '/admin_api/,/password/p' ${HOME}/code/cba-deploy/inventory/dynamic/config/${dc}/${1}/secret.yml | sed -n "s/.*password: '\(.*\)'/\1/p")
    echo "cba-api:${ta_pwd}"
}

read_jira_component_versions_for() {
    [ $# = 0 ] && return 0
    [ $# != 1 ] && echo "usage: $0 <jira>" && return 1
    local pt_tag_image=docker-dev-artifactory.workday.com/pt/opseng/pt_tag
    local jp=$(sed -n '/buildadm-prod:/,/pw/p' ${HOME}/code/cba-deploy/inventory/dynamic/config/pdx/eng/ci/v2/secret.yml | sed -n "s/.*pw: \"\(.*\)\"/\1/p")
    echo $(docker container run --rm  ${pt_tag_image} --jira-user=pt-prod-buildadm --jira-password=${jp} --jira=${1} component-versions)
}

read_console_component_versions_for() {
    [ $# = 0 ] && return 0
    [ $# != 2 ] && echo "usage: $0 <console pseudo artifact name> <version>" && return 1
    local pt_tag_image=docker-dev-artifactory.workday.com/pt/opseng/pt_tag
    local jp=$(sed -n '/buildadm-prod:/,/pw/p' ${HOME}/code/cba-deploy/inventory/dynamic/config/pdx/eng/ci/v2/secret.yml | sed -n "s/.*pw: \"\(.*\)\"/\1/p")
    echo $(docker container run --rm  ${pt_tag_image} --console-user=pt-prod-buildadm --console-password=${jp} -s ${1} -v ${2} component-versions)
}

########################
# Scheduling functions
pt_get_service_deploy_schedule() {
    [ $# != 2 ] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    service=$1
    ptenv=$2
    envs=($(get_env_group ${2}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo -n ${admin_info[1]}': '
        curl -u $(admin_auth ${admin_info[2]}) -X GET ${admin_info[1]}:443/${service}/deploy/schedule
        echo ""
    done
}

pt_set_service_deploy_schedule() {
    [ $# != 4 ] && echo "usage: $0 <service> <environment|environment_group> <deploy_time> <jira>" && return 1
    service=$1
    deploy_date=$3
    jira=$4
    envs=($(get_env_group ${2}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo -n ${admin_info[1]}': '
        curl -u $(admin_auth ${admin_info[2]}) -X POST ${admin_info[1]}:443/${service}/deploy/schedule\?time=${deploy_date}\&jira=${jira}
        echo ""
    done
}

pt_del_service_deploy_schedule() {
    [ $# != 2 ] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    service=$1
    envs=($(get_env_group ${2}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo -n ${admin_info[1]}': '
        curl -u $(admin_auth ${admin_info[2]}) -X DELETE ${admin_info[1]}:443/${service}/deploy/schedule
        echo ""
    done
}

pt_get_service_deploy_log() {
    service=$1
    ptenv=$2
    admin_info=($(lookup_adminhost ${ptenv}))
    curl -u $(admin_auth ${admin_info[2]}) -X GET ${admin_info[1]}:443/${service}/deploy/log
}

# Generic functions for interacting w/ admin API
pt_get() {
    ptenv=$1
    uri=$2
    admin_info=($(lookup_adminhost ${ptenv}))
    curl -su $(admin_auth ${admin_info[2]}) -X GET ${admin_info[1]}:443/${uri}
}

pt_post() {
    ptenv=$1
    uri=$2
    admin_info=($(lookup_adminhost ${ptenv}))
    curl -su $(admin_auth ${admin_info[2]}) -X POST ${admin_info[1]}:443/${uri}
}

pt_delete() {
    ptenv=$1
    uri=$2
    admin_info=($(lookup_adminhost ${ptenv}))
    curl -su $(admin_auth ${admin_info[2]}) -X DELETE ${admin_info[1]}:443/${uri}
}

check_is_dr() {
  ptenv=$1
  local drs=(atldr amsdr ashdr)
  for ((i=1;i <= ${#drs[@]};i++)) {
    if [[ "${drs[$i]}" == "${ptenv}" ]]; then
      echo "y"
      return 0
    fi
  }
  echo "n"
  return 1
}

pt_clean_dr() {
  ptenv=$1
  if [[ $(check_is_dr $ptenv) != "y" ]] ; then
    echo "$ptenv is NOT a DR site - exiting"
    return 1
  fi
  declare -a admin_info
  admin_info=($(lookup_adminhost ${ptenv}))
  tenant_list=$(pt_get $ptenv worksheets/tenants | jq -r '.[]' | grep -v 'envops_gms')
  while read -r tenant ; do
    echo "Deleting ${tenant}"
    pt_delete ${ptenv} worksheets/tenant/${tenant}
  done <<< "${tenant_list}"
}

pt_techops() {
  echo "This will create a message you can copy into #techops for incident escalation"

  echo "What is the FULL JIRA link to the issue you are raising?: "
  echo -n "> "
  read PT_JIRA
  PT_JIRA=${PT_JIRA%$'\r'}

  echo "List the Engineers involved in this issue (ex. @aaron.nichols @tyler.knodell)"
  echo -n "> "
  read PT_ENGINEERS
  PT_ENGINEERS=${PT_ENGINEERS%$'\r'}

  echo "Provide an explanation of the issue you are raising."
  echo "Example: Tenant impacting problem for \`faketenant\` causing Worksheets unavailable"
  echo -n "> "
  read PT_DESCRIPTION
  PT_DESCRIPTION=${PT_DESCRIPTION%$'\r'}

  echo "What is the priority of the JIRA? (Major, Critical, Blocker)"
  echo -n "> "
  read PT_PRIORITY
  PT_PRIORITY=${PT_PRIORITY%$'\r'}

  echo "Is this issue customer impacting? [ y/n ]"
  echo -n "> "
  read PT_CUST_IMPACT
  PT_CUST_IMPACT=${PT_CUST_IMPACT%$'\r'}
  if [[ $PT_CUST_IMPACT == 'y' || $PT_CUST_IMPACT == 'Y' ]] ; then
    PT_NOTIFY_GROUPS="@NOC @support"
  else
    PT_NOTIFY_GROUPS="@NOC"
  fi

  echo "Is there already a sidechat for this issue? If so what is the channel name? (leave blank if none)"
  echo -n "> "
  read PT_SIDECHAT
  PT_SIDECHAT=${PT_SIDECHAT%$'\r'}
  if [[ $PT_SIDECHAT -eq "" ]] ; then
    PT_SIDECHAT="No Chat Created"
  fi


  echo "\`Incident - PT OpsEng\`"
  echo "\`PT Ops Engineers: \` $PT_ENGINEERS"
  echo "$PT_NOTIFY_GROUPS : $PT_DESCRIPTION"
  echo "\`Jira\`: $PT_JIRA"
  echo "\`Priority\`: $PT_PRIORITY"
  echo "\`Sidechat\`: $PT_SIDECHAT"
}

get_rsa_token () {
local TOKEN=$(osascript <<'END'
  -- Get currently focused window
  tell application "System Events"
  set focusedApp to name of the first process whose frontmost is true

  try
      copy (get the clipboard as string) to origClip
      on error strErrorMessage number intErrorNumber
      if (intErrorNumber is -25131) or (intErrorNumber is -1700) then
          set origClip to ""
      end if
  end try
  end tell

  tell application "SecurID"
  activate
  delay 0.3
  tell application "System Events"
  delay 0.3
  keystroke "c" using command down
  delay 0.5 -- Time to populate clipboard
  copy (get the clipboard as string) to theToken
  #set the clipboard to origClip
  if (theToken is equal to origClip) then
      set theToken to ""
  end if
  end tell
  end tell
  -- Set the focus back to where it started...
  tell application focusedApp to activate

  return theToken
END
)
echo $TOKEN
}

function sshrsa () {
  # ask for password if not set
  if [ -z ${PASSWORD+x} ] ; then
    echo "Enter RSA PIN: "
    read -s PASSWORD
    export PASSWORD
  fi
  RSA_TOKEN=$(get_rsa_token)
  if [ -z $RSA_TOKEN ]; then
    echo "Failed to aquire token from SecurID, please retry"
  else
    export SSHPASS="${PASSWORD}${RSA_TOKEN}"
    sshpass -v -P "Enter PASSCODE:" -e ssh $1
  fi
  unset SSHPASS
}
function kill_securid () {
  osascript <<'END'
  tell application "System Events"
            set ProcessList to name of every process
            if "SecurID" is in ProcessList then
                      set ThePID to unix id of process "SecurID"
                      do shell script "kill -KILL " & ThePID
            end if
  end tell
END
}
