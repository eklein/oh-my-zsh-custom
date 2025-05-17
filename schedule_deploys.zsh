#!/usr/bin/env zsh
#
set_times() {
  declare -gA schedule
  #worksheets
  schedule[sales_worksheets]="Fri 19:00"
  schedule[impl_worksheets]="Fri 19:00"
  schedule[prod_worksheets]="Sat 00:00"
  schedule[dr_worksheets]="Fri ${DR_DEPLOY_TIME:-12:00}"

  #drive
  schedule[sales_drive]="Fri 19:00"
  schedule[impl_drive]="Fri 19:00"
  schedule[prod_drive]="Sat 00:00"
  schedule[dr_drive]="Fri ${DR_DEPLOY_TIME:-12:00}"

  # talk
  schedule[sales_talk]="Fri 19:00"
  schedule[impl_talk]="Fri 19:00"
  schedule[prod_talk]="Sat 00:00"
  schedule[dr_talk]="Fri ${DR_DEPLOY_TIME:-12:00}"

  # assistant
  schedule[sales_assistant]="Fri 19:00"
  schedule[impl_assistant]="Fri 19:00"
  schedule[prod_assistant]="Sat 00:00"
  schedule[dr_assistant]="Fri ${DR_DEPLOY_TIME:-12:00}"
}

get_date_from_day() {
  DAY=${1% *}
  TIME=${1#* }
  echo "$(date -v+$DAY "+%Y-%m-%d")T$TIME"
}

schedule_deploys_usage() {
  echo "Error:"
  echo "example usage:"
  echo "schedule_deploys worksheets <console artifact version>"
  echo "schedule_deploys drive <console artifact version>"
  echo "schedule_deploys talk <console artifact version>"
  echo "schedule_deploys assistant <console artifact version>"
}

schedule_dr_deploys_usage() {
  echo "Error:"
  echo "example usage:"
  echo "schedule_dr_deploys worksheets <console artifact version>"
  echo "schedule_dr_deploys drive <console artifact version>"
  echo "schedule_dr_deploys talk <console artifact version>"
  echo "schedule_dr_deploys assistant <console artifact version>"
}

run_schedule_deploy() {
  local SERVICE=$1
  local ENV=$2
  local DATE_TIME=$3
  local DEPLOY_ARTIFACT_VERSION=$4
  pt_mop_set_service_deploy_schedule ${SERVICE} ${ENV} $(get_date_from_day ${DATE_TIME}) ${DEPLOY_ARTIFACT_VERSION}
}

show_schedule_deploy() {
  local SERVICE=$1
  local ENV=$2
  local DATE_TIME=$3
  local DEPLOY_ARTIFACT_VERSION=$4
  echo "pt_mop_set_service_deploy_schedule ${SERVICE} ${ENV} $(get_date_from_day ${DATE_TIME}) ${DEPLOY_ARTIFACT_VERSION}"
}

check_mop_url() {
  curl -k $MOP_URL/health -f &>/dev/null
  exit_status=$?
  if [ $exit_status -ne 0 ] ; then
    echo "${MOP_URL}/health is not healthy"
  fi
  return $exit_status
}

schedule_deploys() {
  check_mop_url || return 2
  set_times
  local SERVICE=$1
  local DEPLOY_ARTIFACT_VERSION=$2
  echo "Will run the following to schedule deploys:"
  if [[ $SERVICE =~ 'worksheets|drive|talk|assistant' ]] && [ ! -z $DEPLOY_ARTIFACT_VERSION ]; then
    show_schedule_deploy $SERVICE sales $schedule[sales_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
    show_schedule_deploy $SERVICE impl  $schedule[impl_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
    show_schedule_deploy $SERVICE prod $schedule[prod_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
  else
    schedule_deploys_usage
    return
  fi
  echo
  read "response?Do you want to schedule the deploys? [Yes|No] "
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
    if [[ $SERVICE =~ 'worksheets|drive|talk|assistant' ]] && [ ! -z $DEPLOY_ARTIFACT_VERSION ]; then
        run_schedule_deploy $SERVICE sales $schedule[sales_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
        run_schedule_deploy $SERVICE impl $schedule[impl_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
        run_schedule_deploy $SERVICE prod $schedule[prod_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
    else
      schedule_deploys_usage
      return
    fi
  else
    echo "Ok Bye"
  fi
}

schedule_dr_deploys() {
  check_mop_url || return 2
  set_times
  local SERVICE=$1
  local DEPLOY_ARTIFACT_VERSION=$2
  echo "Will run the following to schedule deploys:"
  if [[ $SERVICE =~ 'worksheets|drive|talk|assistant' ]] && [ ! -z $DEPLOY_ARTIFACT_VERSION ]; then
    show_schedule_deploy ${SERVICE} dr $schedule[dr_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
  else
    schedule_dr_deploys_usage
    return
  fi
  echo
  read "response?Do you want to schedule the deploys? [Yes|No] "
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
    if [[ $SERVICE =~ 'worksheets|drive|talk|assistant' ]] && [ ! -z $DEPLOY_ARTIFACT_VERSION ]; then
        run_schedule_deploy ${SERVICE} dr $schedule[dr_$SERVICE] ${DEPLOY_ARTIFACT_VERSION}
    else
      schedule_dr_deploys_usage
      return
    fi
  else
    echo "Ok Bye"
  fi
}
