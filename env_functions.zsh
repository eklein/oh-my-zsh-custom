pt_list_environments() {
    echo "<shortname> -> <hostname> <cred_type> <mop_env>\n"
    lookup_adminhost "all"
}

pt_list_environment_groups() {
    get_env_group "all"
}

pt_list_service_environments() {
    get_service_environments "all"
}

get_env_group() {
    [ $# != 1 ] && echo "usage: $0 <environment|environment_group>" && return 1
    declare -A env

    env[svt]="svtprod svtprod2 svtint svtauto"
    env[svtall]="${env[svt]}"
    env[eng]="${env[svt]} pdxperf tsint master opsmgmt qaprod tm qarc"
    env[engall]="${env[eng]}"
    env[impl]="atlnprd dubnprd pdxnprd"
    env[implall]="${env[impl]}"
    env[sales]="atlsales1 atlsales2"
    env[salesall]="${env[sales]}"
    env[nprd]="${env[sales]} ${env[impl]} atlperf"
    env[nprdall]="${env[nprd]}"
    env[icv]="pdxicv pdxicfv-curr pdxicfv-next pdxprcv-curr pdxprcv-next"
    env[prod]="ashprod dubprod pdxprod"
    env[prodall]="${env[prod]}"
    env[dr]="ashdr amsdr atldr"
    env[drall]="${env[dr]}"
    env[custall]="${env[drall]} ${env[prodall]} ${env[nprdall]}"

    if [[ $1 == "all" ]]; then
        for key in "${(k@)env}" ; do
            echo "$key -> ${env[$key]}"
        done | sort -n -k3
    elif [[ -n "${env[${1}]}" ]]; then
        echo ${env[${1}]}
    else
        echo ${1}
    fi
}

#
# NOTE: atlperf has been added to the nprd groups because those are used to build service templates
#       atlperf was not added to impl, because those are used for scheduling
#
get_service_environments() {
    [[ $1 != "all" && $# != 2 ]] && echo "usage: $0 <service> <environment|environment_group>" && return 1
    declare -A drive talk worksheets deploy_template

    drive[svt]="$(get_env_group svt)"
    drive[impl]="$(get_env_group impl)"
    drive[sales]="$(get_env_group sales)"
    drive[nprd]="${drive[impl]} ${drive[sales]} atlperf"
    drive[prod]="$(get_env_group prod)"
    drive[dr]="$(get_env_group dr)"

    talk[impl]="pdxnprd atlnprd dubnprd"
    talk[sales]="$(get_env_group sales)"
    talk[nprd]="${talk[impl]} ${talk[sales]}"
    talk[prod]="pdxprod ashprod dubprod"
    talk[dr]="ashdr atldr amsdr"

    worksheets[svt]="$(get_env_group svt)"
    worksheets[impl]="$(get_env_group impl)"
    worksheets[sales]="$(get_env_group sales)"
    worksheets[nprd]="${worksheets[impl]} ${worksheets[sales]} atlperf"
    worksheets[prod]="$(get_env_group prod)"
    worksheets[dr]="$(get_env_group dr)"

    deploy_template[svt]="svtprod"
    deploy_template[nprd]="$(get_env_group impl)"
    deploy_template[prod]="$(get_env_group prod)"
    deploy_template[dr]="$(get_env_group dr)"

    if [[ $1 == "all" ]]; then
        echo
        for svc in deploy_template worksheets drive talk; do
            echo "${(C)svc}:"
            for key in $(eval echo \${\(k@\)${svc}\}) ; do
                val=$(eval echo \$\{${svc}\[${key}\]\})
                echo "  $key -> ${val}"
            done | sort -n -k3
            echo
        done
    elif [[ -n "$(eval echo \$\{${1}\[${2}\]\})" ]]; then
        echo $(eval echo \$\{${1}\[${2}\]\})
    else
        echo ${2}
    fi
}

# return appropriate admin host
lookup_adminhost() {
    declare -A pt_admin


    # NPRD
    pt_admin[atlnprd]="admin-impl-0001.pt.az1.cust.atl.wd nprd atlnprdimpl"
    pt_admin[atlperf]="admin-perf-0001.pt.az1.cust.atl.wd nprd atlnprdperf"
    pt_admin[dubnprd]="admin-impl-0001.pt.az1.cust.dub.wd nprd dubnprdimpl"
    pt_admin[pdxnprd]="admin-impl-0001.pt.az1.cust.pdx.wd nprd pdxnprdimpl"
    pt_admin[atlsales1]="admin-sales1-0001.pt.az1.cust.atl.wd nprd atlnprdsales1"
    pt_admin[atlsales2]="admin-sales2-0001.pt.az1.cust.atl.wd nprd atlnprdsales2"
    pt_admin[pdxicv]="admin-icv-0001.pt.az1.cust.pdx.wd nprd pdxnprdcticv"
    pt_admin[pdxprcv-curr]="admin-prcv-curr-0001.pt.az1.cust.pdx.wd nprd pdxnprdctprcv-curr"
    pt_admin[pdxprcv-next]="admin-prcv-next-0001.pt.az1.cust.pdx.wd nprd pdxnprdctprcv-next"
    pt_admin[pdxicfv-curr]="admin-icfv-curr-0001.pt.az1.cust.pdx.wd nprd pdxnprdcticfv-curr"
    pt_admin[pdxicfv-next]="admin-icfv-next-0001.pt.az1.cust.pdx.wd nprd pdxnprdcticfv-next"

    # PROD
    pt_admin[ashprod]="admin-prod-0001.pt.az1.cust.ash.wd prod ashprod"
    pt_admin[dubprod]="admin-prod-0001.pt.az1.cust.dub.wd prod dubprod"
    pt_admin[pdxprod]="admin-prod-0001.pt.az1.cust.pdx.wd prod pdxprod"

    # DR
    pt_admin[ashdr]="admin-dr-0001.pt.az1.cust.ash.wd prod ashdr"
    pt_admin[atldr]="admin-dr-0001.pt.az1.cust.atl.wd prod atldr"
    pt_admin[amsdr]="admin-dr-0001.pt.az1.cust.ams.wd prod amsdr"

    # PDX-ENG
    pt_admin[pdxeng]="admin-0001.pt.az1.eng.pdx.wd eng pdxengadmin"
    pt_admin[tsint]="admin-tsint-0001.pt.az1.eng.pdx.wd eng pdxengdevqainttsint"
    pt_admin[svtprod]="admin-svtprod-0001.pt.az1.eng.pdx.wd eng pdxengsvtprod"
    pt_admin[svtprod2]="admin-svtprod2-0001.pt.az1.eng.pdx.wd eng pdxengsvtprod2"
    pt_admin[svtint]="admin-svtint-0001.pt.az1.eng.pdx.wd eng pdxengsvtint"
    pt_admin[svtauto]="admin-svtauto-0001.pt.az1.eng.pdx.wd eng pdxengsvtauto"
    pt_admin[ttint]="admin-ttint-0001.pt.az1.eng.pdx.wd eng pdxengttint"
    pt_admin[warpint]="admin-warpint-0001.pt.az1.eng.pdx.wd eng pdxengdevqaintwarpint"
    pt_admin[warp]="admin-warp-0001.pt.az1.eng.pdx.wd eng pdxengwarp"
    pt_admin[qaint]="admin-qaint-0001.pt.az1.eng.pdx.wd eng pdxengdevqaintqaint"
    pt_admin[qaprod]="admin-qaprod-0001.pt.az1.eng.pdx.wd eng pdxengdevqaprodqaprod"
    pt_admin[master]="admin-master-0001.pt.az1.eng.pdx.wd eng pdxengdevqaprodmaster"
    pt_admin[opsmgmt]="admin-ops-0001.pt.az1.eng.pdx.wd eng pdxengopsmgmt"
    pt_admin[pdxperf]="admin-perf-0001.pt.az1.eng.pdx.wd eng pdxengperf"
    pt_admin[tm]="admin-tm-0001.pt.az1.eng.pdx.wd eng pdxengdevqaprodtm"
    pt_admin[qarc]="admin-qarc-0001.pt.az1.eng.pdx.wd eng pdxengdevqaprodqarc"

    # Return a list of environments & associated admin hosts if "all" is
    # passed as argument. Otherwise, return single admin host
    if [[ $1 == "all" ]] ; then
        for key in "${(k@)pt_admin}" ; do
            echo "$key -> ${pt_admin[$key]}"
        done | sort -n -k3
    else
        echo ${pt_admin[$1]}
    fi
}
