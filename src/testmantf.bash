#
###[ embedded-bashlib64-end ]#####################
#

#
# Script Functions
#

function testmantf_container_run() {
  bl64_dbg_app_trace_start
  local -i status=0

  # shellcheck disable=SC2086
  "$TESTMANTF_CMD_CONTAINER" \
    run \
    --rm \
    --volume "${TESTMANTF_ROOT}:/mnt" \
    $_TESTMANTF_EXPORTS_ENV \
    --env TF_CLI_CONFIG_FILE \
    --env TF_DATA_DIR \
    --env TF_LOG_PATH \
    --env TF_PLUGIN_CACHE_DIR \
    --env TF_LOG \
    "$@"
  status=$?

  bl64_dbg_app_trace_stop
  return $status
}

function testmantf_set_workspace() {
  bl64_dbg_app_trace_start
  local container="$1"
  local module="$2"

  _TESTMANTF_TEST_LOCK="$_TESTMANTF_TEST_TARGET/.terraform.lock.hcl"
  TF_DATA_DIR="${TESTMANTF_VAR}/${module}"
  TF_PLUGIN_CACHE_DIR="${TESTMANTF_CACHE}/${module}"
  [[ ! -d "$TF_DATA_DIR" ]] && bl64_os_mkdir_full "$TF_DATA_DIR"
  [[ ! -d "$TF_PLUGIN_CACHE_DIR" ]] && bl64_os_mkdir_full "$TF_PLUGIN_CACHE_DIR"

  if [[ "$container" == '1' ]]; then
    # Set container variables
    TF_DATA_DIR="/mnt/$(bl64_fmt_basename "${TESTMANTF_VAR}")/${module}"
    TF_PLUGIN_CACHE_DIR="/mnt/$(bl64_fmt_basename "${TESTMANTF_CACHE}")/${module}"
    TF_CLI_CONFIG_FILE="/mnt/$(bl64_fmt_basename "${TESTMANTF_TEST}")/terraformrc.hcl"

    # Modify paths for container run
    _TESTMANTF_EXPORTS_ENV="${_TESTMANTF_TEST_TARGET}/exports.env"
    [[ -f "$_TESTMANTF_EXPORTS_ENV" ]] && _TESTMANTF_EXPORTS_ENV="--env-file ${_TESTMANTF_EXPORTS_ENV}" || _TESTMANTF_EXPORTS_ENV=''
    _TESTMANTF_TEST_TARGET="/mnt/test/${module}"

  else
    TF_CLI_CONFIG_FILE="${TESTMANTF_TEST}/terraformrc.hcl"
  fi
  TF_LOG_PATH="${TF_DATA_DIR}/terraform.log"
  _TESTMANTF_TEST_TFSTATE="${TF_PLUGIN_CACHE_DIR}/terraform.tfstate"

  bl64_dbg_app_trace_stop
  return 0
}

function testmantf_cleanup() {
  local module="$1"
  local container="$2"
  local image="$3"

  testmantf_set_workspace "$container" "$module"

  bl64_os_rm_full "${TF_PLUGIN_CACHE_DIR}/registry.terraform.io"
  bl64_os_rm_full "${TF_DATA_DIR}/modules"
  bl64_os_rm_full "${TF_DATA_DIR}/providers"
  bl64_os_rm_file "$_TESTMANTF_TEST_TFSTATE"
  bl64_os_rm_file "$TF_LOG_PATH"
  bl64_os_rm_file "$_TESTMANTF_TEST_LOCK"
  return 0
}

function testmantf_init() {
  local module="$1"
  local container="$2"
  local image="$3"

  bl64_msg_show_task 'initialize workspace'
  testmantf_set_workspace "$container" "$module"
  if [[ "$container" == '0' ]]; then
    cd "$_TESTMANTF_TEST_TARGET"
    "$TESTMANTF_CMD_TERRAFORM" \
      'init' \
      -backend-config="path=$_TESTMANTF_TEST_TFSTATE" || return $?
  else
    testmantf_container_run \
      "$image" \
      -chdir="$_TESTMANTF_TEST_TARGET" \
      'init' \
      -backend-config="path=$_TESTMANTF_TEST_TFSTATE" || return $?
  fi
}

function testmantf_run() {
  local module="$1"
  local container="$2"
  local image="$3"

  testmantf_init "$module" "$container" "$image"

  bl64_msg_show_task 'apply changes'
  if [[ "$container" == '0' ]]; then
    "$TESTMANTF_CMD_TERRAFORM" \
      'apply' \
      -auto-approve
  else
    testmantf_container_run "$image" \
      -chdir="$_TESTMANTF_TEST_TARGET" \
      'apply' \
      -auto-approve
  fi
}

function testmantf_destroy() {
  local module="$1"
  local container="$2"
  local image="$3"

  testmantf_init "$module" "$container" "$image"

  bl64_msg_show_task 'destroy infrastructure'
  if [[ "$container" == '0' ]]; then
    "$TESTMANTF_CMD_TERRAFORM" \
      'apply' \
      -destroy \
      -auto-approve
  else
    testmantf_container_run "$image" \
      -chdir="$_TESTMANTF_TEST_TARGET" \
      'apply' \
      -destroy \
      -auto-approve
  fi
}

function testmantf_show() {
  local module="$1"
  local container="$2"
  local image="$3"

  testmantf_init "$module" "$container" "$image"

  bl64_msg_show_task 'show current infrastructure'
  if [[ "$container" == '0' ]]; then
    "$TESTMANTF_CMD_TERRAFORM" \
      'show'
  else
    testmantf_container_run "$image" \
      -chdir="$_TESTMANTF_TEST_TARGET" \
      'show'
  fi
}

function testmantf_check() {
  bl64_check_directory "$TESTMANTF_TEST" &&
    bl64_check_directory "$TESTMANTF_VAR" &&
    bl64_check_directory "$TESTMANTF_CACHE" &&
    bl64_check_directory "$_TESTMANTF_TEST_TARGET" || return 1

  if [[ "$testmantf_container_mode" == '1' ]]; then
    bl64_check_command "$TESTMANTF_CMD_CONTAINER" || return 1
  else
    bl64_check_command "$TESTMANTF_CMD_TERRAFORM" || return 1
  fi
  return 0
}

function testmantf_set_exports() {
  bl64_dbg_app_trace_start

  # Declare script exports
  export TESTMANTF_ROOT
  export TESTMANTF_TEST
  export TESTMANTF_VAR
  export TESTMANTF_CACHE
  export TESTMANTF_CMD_TERRAFORM
  export TESTMANTF_CMD_CONTAINER

  # Declare Terraform exports
  export TF_CLI_CONFIG_FILE
  export TF_DATA_DIR
  export TF_LOG_PATH
  export TF_PLUGIN_CACHE_DIR
  export TF_LOG

  TESTMANTF_CMD_CONTAINER="${TESTMANTF_CMD_CONTAINER:-/usr/bin/podman}"
  TESTMANTF_CMD_TERRAFORM="${TESTMANTF_CMD_TERRAFORM:-/usr/bin/terraform}"

  TESTMANTF_ROOT="${TESTMANTF_ROOT:-.}"
  TESTMANTF_TEST="${TESTMANTF_TEST:-${TESTMANTF_ROOT}/test}"
  TESTMANTF_VAR="${TESTMANTF_VAR:-${TESTMANTF_ROOT}/.var}"
  TESTMANTF_CACHE="${TESTMANTF_CACHE:-${TESTMANTF_ROOT}/.cache}"

  bl64_dbg_app_trace_stop
}

function testmantf_help() {
  bl64_msg_show_usage \
    '<-t|-d|-s|-c> -n Module [-i Image] [-o] [-D Level] [-h]' \
    'Test Terraform modules' \
    '
    -t       : Run module test (terraform init, terraform apply)
    -d       : Destroy module test infrastructure (terraform destroy)
    -s       : Show current test infrastructure (terraform show)
    -c       : Clean test environment
    ' '
    -o       : Enable container mode (run actions inside a container)
    -h       : Show help
    ' "
    -n Module: module name
    -i Image : container image name (default: $testmantf_image)
    -D Level : debug level
    "
}

#
# Main
#

declare _TESTMANTF_EXPORTS_ENV=''
declare _TESTMANTF_TEST_LOCK=''
declare _TESTMANTF_TEST_TARGET=''
declare _TESTMANTF_TEST_TFSTATE=''

declare testmantf_status=1
declare testmantf_container_mode='0'
declare testmantf_command=''
declare testmantf_run=''
declare testmantf_option=''
declare testmantf_image='docker.io/hashicorp/terraform:latest'

(($# == 0)) && testmantf_help && exit 1
while getopts ':tdscn:i:oD:h' testmantf_option; do
  case "$testmantf_option" in
  t)
    testmantf_command='testmantf_run'
    testmantf_command_tag='test module'
    ;;
  d)
    testmantf_command='testmantf_destroy'
    testmantf_command_tag='destroy previous test'
    ;;
  s)
    testmantf_command='testmantf_show'
    testmantf_command_tag='show current test infrastructure'
    ;;
  c)
    testmantf_command='testmantf_cleanup'
    testmantf_command_tag='cleanup test environment'
    ;;
  o)
    testmantf_container_mode='1'
    testmantf_command_tag='enable container mode'
    ;;
  i) testmantf_image="$OPTARG" ;;
  n) testmantf_run="$OPTARG" ;;
  D) BL64_LIB_DEBUG="$OPTARG" ;;
  h) testmantf_help && exit ;;
  \?) testmantf_help && exit 1 ;;
  esac
done
[[ -z "$testmantf_command" || -z "$testmantf_run" ]] && testmantf_help && exit 1
testmantf_set_exports
_TESTMANTF_TEST_TARGET="${TESTMANTF_TEST}/${testmantf_run}"
testmantf_check || exit 1

bl64_msg_show_batch_start "$testmantf_command_tag"
case "$testmantf_command" in
'testmantf_cleanup' | 'testmantf_run' | 'testmantf_destroy' | 'testmantf_show')
  "$testmantf_command" "$testmantf_run" "$testmantf_container_mode" "$testmantf_image"
  ;;
esac
testmantf_status=$?

bl64_msg_show_batch_finish $testmantf_status "$testmantf_command_tag"
exit $testmantf_status
