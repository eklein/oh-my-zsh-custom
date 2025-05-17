# MoP commands
#
MOP_URL="https://mop-0001.pt.az1.eng.pdx.wd:5671"
GOOPS_DIR="${GOOPS_ROOT:-$HOME/code/goops}"

mop_auth() {
    cat ~/.mop-passwd
}

alias mopctl="docker container run --rm \
                -v ${HOME}/.mopctl:/config:ro \
                -v ${GOOPS_DIR}/configs/mop/client/env.json:/home/wday/code/workstation/support/env.json \
                -v ${GOOPS_DIR}/configs/mop/client/env-scylla.json:/home/wday/code/workstation/support/env-scylla.json \
                -v ${HOME}/ansible_local:/ansible_local \
                docker-dev-artifactory.workday.com/pt/opseng/mop/client:latest"

mop_shared_secret() {
    cat ~/.mop-shared-secret
}

sendHttpRequest() {
    [ $# -lt 2 ] && echo "usage: $0 <admin_info> <command> [<args>]" && return 1
    if [ $# -eq 2 ]; then
        http --verify no --auth "$(mop_auth)" POST ${MOP_URL}/ops/job/${1} command="${2}" secret="$(mop_shared_secret)"
    else
        http --verify no --auth "$(mop_auth)" POST ${MOP_URL}/ops/job/${1} command="${2}" secret="$(mop_shared_secret)" args:="${3}"
    fi
}

get_console_pseudo_artifact_name() {
    declare -A services

    services[Worksheets]="worksheets-deploy"
    services[Drive]="workdrive-deploy"
    services[Talk]="worktalk-deploy"

    echo ${services[$1]}
}

pt_mop_pull_ansible() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - PullLatestAnsible"
	sendHttpRequest "${admin_info[3]}" "PullLatestAnsible"
    done
}

pt_mop_ansible_id() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - GetAnsibleID"
	sendHttpRequest "${admin_info[3]}" "GetAnsibleID"
    done
}

pt_mop_build_deploy_template() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_service_environments deploy_template ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - BuildDeployTemplate"
	sendHttpRequest "${admin_info[3]}" "BuildDeployTemplate"
    done
}

pt_mop_build_service_templates() {
    [ $# != 2 ] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    pt_mop_build_service_templates_with_validation "$@" ""
}

pt_mop_build_service_templates_with_validation() {
    [ $# != 3 ] && echo "usage: $0 <service> <environment|environment_group> <version>" && return 1
    service=${(C)1}
    console_service=($(get_console_pseudo_artifact_name $service))
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_console_component_versions_for $console_service ${3})
    args="[\"${component_versions}\"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Build${service}Templates"
        sendHttpRequest "${admin_info[3]}" "Build${service}Templates" "${args}"
    done
}

pt_mop_build_service_templates_with_validation_jira() {
    [ $# != 3 ] && echo "usage: $0 <service> <environment|environment_group> <jira>" && return 1
    service=${(C)1}
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_jira_component_versions_for ${3})
    args="[\"${component_versions}\"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Build${service}Templates"
        sendHttpRequest "${admin_info[3]}" "Build${service}Templates" "${args}"
    done
}

pt_mop_deploy_service() {
    [ $# != 3 ] && echo "usage: $0 <service> <environment|environment_group> <version>" && return 1
    service=${(C)1}
    console_service=($(get_console_pseudo_artifact_name $service))
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_console_component_versions_for $console_service ${3})
    args="[\"${component_versions}\"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Deploy${service}"
        sendHttpRequest "${admin_info[3]}" "Deploy${service}" "${args}"
    done
}

pt_mop_deploy_service_jira() {
    [ $# != 3 ] && echo "usage: $0 <service> <environment|environment_group> <jira>" && return 1
    service=${(C)1}
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_jira_component_versions_for ${3})
    args="[\"${component_versions}\"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Deploy${service}"
        sendHttpRequest "${admin_info[3]}" "Deploy${service}" "${args}"
    done
}

pt_mop_deploy_sensu() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - DeploySensuStack"
        sendHttpRequest "${admin_info[3]}" "DeploySensuStack"
    done
}

pt_mop_deploy_pingthru() {
    [ $# != 2 ] && echo "usage: $0 <environment|environment_group> <image>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - DeployPingthruCheck"
	sendHttpRequest "${admin_info[3]}" "DeployPingthruCheck" "[\"${2}\"]"
    done
}

pt_mop_deploy_toggles() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - DeployToggles"
	sendHttpRequest "${admin_info[3]}" "DeployToggles"
    done
}

pt_mop_get_jobs() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - GetJobs"
        http --verify no --auth "$(mop_auth)" ${MOP_URL}/ops/jobs/${admin_info[3]}
    done
}

########################
# Scheduling functions
pt_mop_get_service_deploy_schedule() {
    [ $# != 2 ] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    service=${(C)1}
    envs=($(get_service_environments ${1} ${2}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - GetScheduled${service}Deploy"
        sendHttpRequest "${admin_info[3]}" "GetScheduled${service}Deploy"
    done
}

pt_mop_set_service_deploy_schedule() {
    [ $# -lt 4 ] && echo "usage: $0 <service> <environment|environment_group> <deploy_date> <deploy_pseudo_artifact_version>" && return 1
    service=${(C)1}
    console_service=($(get_console_pseudo_artifact_name $service))
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_console_component_versions_for $console_service ${4})
    args_start="[\"${4}\",\"${3}\",\"${component_versions}\""
    args=${args_start}"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Schedule${service}Deploy"
        sendHttpRequest "${admin_info[3]}" "Schedule${service}Deploy" "${args}"
    done
}

pt_mop_set_service_deploy_schedule_jira() {
    [ $# -lt 4 ] && echo "usage: $0 <service> <environment|environment_group> <deploy_date> <deploy_jira_with_versions> <(optional) provision_jira> <(optional) tenant_to_deploy>" && return 1
    if [ "${5}" = "not_provided" ]; then
        jira_for_notification=${4}
    else
        jira_for_notification=${5}
    fi
    service=${(C)1}
    envs=($(get_service_environments ${1} ${2}))
    component_versions=$(read_jira_component_versions_for ${4})
    args_start="[\"${jira_for_notification}\",\"${3}\",\"${component_versions}\""
    if [ -n "${6}" ]; then
        args_start=${args_start}",\"${6}\""
    fi
    args=${args_start}"]"
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - Schedule${service}Deploy"
        sendHttpRequest "${admin_info[3]}" "Schedule${service}Deploy" "${args}"
    done
}

pt_mop_del_service_deploy_schedule() {
    [ $# != 2 ] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    service=${(C)1}
    envs=($(get_service_environments ${1} ${2}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - StopScheduled${service}Deploy"
        sendHttpRequest "${admin_info[3]}" "StopScheduled${service}Deploy"
    done
}

#Schedule stop worksheets commands
pt_mop_get_stop_worksheets_schedule() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - GetScheduledStopWorksheets"
        sendHttpRequest "${admin_info[3]}" "GetScheduledStopWorksheets"
    done
}

pt_mop_set_stop_worksheets_schedule() {
    [ $# -lt 2 ] && echo "usage: $0 <environment|environment_group> <schedule_date_time>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    args_start="[\"${jira_for_notification}\",\"${3}\",\"${component_versions}\""
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - ScheduleStopWorksheets"
        sendHttpRequest "${admin_info[3]}" "ScheduleStopWorksheets" "[\"${2}\"]"
    done
}

pt_mop_del_stop_worksheets_schedule() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - StopScheduledStopWorksheets"
        sendHttpRequest "${admin_info[3]}" "StopScheduledStopWorksheets"
    done
}

#Schedule worksheets toggle deploy
pt_mop_get_toggle_deploy_schedule() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - GetScheduledToggleDeploy"
	      sendHttpRequest "${admin_info[3]}" "GetScheduledToggleDeploy"
    done
}

pt_mop_set_toggle_deploy_schedule() {
    [ $# -lt 2 ] && echo "usage: $0 <environment|environment_group> <schedule_date_time>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - ScheduleToggleDeploy"
        sendHttpRequest "${admin_info[3]}" "ScheduleToggleDeploy" "[\"${2}\"]"
    done
}

pt_mop_del_toggle_deploy_schedule() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_service_environments 'worksheets' ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
        echo "${admin_info[3]} - StopScheduledToggleDeploy"
        sendHttpRequest "${admin_info[3]}" "StopScheduledToggleDeploy"
    done
}

########################
# Sensu functions
pt_mop_get_sensu_events() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
	sendHttpRequest "${admin_info[3]}" "CheckSensuEvents"
    done
}

pt_mop_get_sensu_health() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
	sendHttpRequest "${admin_info[3]}" "CheckSensuHealth"
    done
}

########################
# Admin functions
pt_mop_deploy_admin_service() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    envs=($(get_env_group ${1}))
    for ptenv in ${envs[@]}; do
        admin_info=($(lookup_adminhost ${ptenv}))
	sendHttpRequest "${admin_info[3]}" "DeployAdminService"
    done
}
