#
# Functions
#

function testmantf_target_prepare() {
  local case="${1:-}"
  local source="${TESTMANTF_LOCAL_TEST_TERRAFORM}/${case}"
  local destination="${TESTMANTF_LOCAL_TMP}/${case}"

  bl64_check_parameter 'case' &&
    bl64_check_directory "$source" || return $?

  testmantf_target_cleanup "$case"

  bl64_msg_show_task "Copy test case to temporal location (${destination})"
  bl64_fs_cp_dir "$source" "$destination" &&
    bl64_fs_run_chmod -R "$TESTMANTF_LOCAL_CASE_MODE" "$destination"
}

function testmantf_target_cleanup() {

  local case="${1:-}"
  local destination="${TESTMANTF_LOCAL_TMP}/${case}"

  bl64_check_parameter 'case' || return $?
  [[ ! -d "$destination" ]] && return 0

  bl64_msg_show_task "Remove test case from temporal location (${destination})"
  bl64_fs_rm_full "$destination"

  return 0
}

function testmantf_terraform_validate() {
  local case="${1:-}"
  local destination=''

  if [[ "$TESTMANTF_CONTAINER_ON" == "$BL64_LIB_VAR_OFF" ]]; then
    bl64_tf_setup "$TESTMANTF_CMD_TERRAFORM" || return $?

    destination="${TESTMANTF_LOCAL_TMP}/${case}"
    bl64_msg_show_task "Lint test case with terraform validate (${destination})"

    cd "${TESTMANTF_LOCAL_TMP}/${case}" &&
      bl64_tf_run_terraform init &&
      bl64_tf_run_terraform validate ||
      return $?
  else
    destination="${TESTMANTF_CONTAINER_TMP}/${case}"
    bl64_msg_show_task "Lint test case with terraform validate (${destination})"

    bl64_cnt_run_interactive \
      --env TESTMANTF_CONTAINER_LIB \
      --volume "${TESTMANTF_LOCAL_ROOT}:${TESTMANTF_CONTAINER_ROOT}" \
      "${TESTMANTF_CONTAINER_REGISTRY}/${TESTMANTF_CONTAINER_IMAGE}" \
      "${TESTMANTF_CONTAINER_TEST_LIB}/testmantf-terraform-validate.bash" \
      "$destination"
  fi

  return 0
}

function testmantf_tflint_lint() {
  local case="${1:-}"
  local destination=''

  if [[ "$TESTMANTF_CONTAINER_ON" == "$BL64_LIB_VAR_OFF" ]]; then

    TESTMANTF_CMD_TFLINT="${TESTMANTF_CMD_TFLINT}/tflint"
    bl64_check_command "$TESTMANTF_CMD_TFLINT" || return $?

    destination="${TESTMANTF_LOCAL_TMP}/${case}"
    bl64_msg_show_task "Lint test case with tflint (${destination})"

    cd "${TESTMANTF_LOCAL_TMP}/${case}" &&
      "$TESTMANTF_CMD_TFLINT" \
        --module \
        --loglevel=warn \
        . ||
      return $?
  else
    destination="${TESTMANTF_CONTAINER_TMP}/${case}"
    bl64_msg_show_task "Lint test case with terraform validate (${destination})"

    bl64_cnt_run_interactive \
      --env TESTMANTF_CONTAINER_LIB \
      --volume "${TESTMANTF_LOCAL_ROOT}:${TESTMANTF_CONTAINER_ROOT}" \
      "${TESTMANTF_CONTAINER_REGISTRY}/${TESTMANTF_CONTAINER_IMAGE}" \
      "${TESTMANTF_CONTAINER_TEST_LIB}/testmantf-tflint-lint.bash" \
      "$destination"
  fi

  return 0
}

function testmantf_tfsec_scan() {
  local case="${1:-}"
  local destination=''

  if [[ "$TESTMANTF_CONTAINER_ON" == "$BL64_LIB_VAR_OFF" ]]; then

    TESTMANTF_CMD_TFSEC="${TESTMANTF_CMD_TFSEC}/tfsec"
    bl64_check_command "$TESTMANTF_CMD_TFSEC" || return $?

    destination="${TESTMANTF_LOCAL_TMP}/${case}"
    bl64_msg_show_task "Scan test case with tfscan (${destination})"

    cd "${TESTMANTF_LOCAL_TMP}/${case}" &&
      "$TESTMANTF_CMD_TFSEC" \
        --concise-output \
        --tfvars-file terraform.tfvars \
        . ||
      return $?
  else
    destination="${TESTMANTF_CONTAINER_TMP}/${case}"
    bl64_msg_show_task "Lint test case with terraform validate (${destination})"

    bl64_cnt_run_interactive \
      --env TESTMANTF_CONTAINER_LIB \
      --volume "${TESTMANTF_LOCAL_ROOT}:${TESTMANTF_CONTAINER_ROOT}" \
      "${TESTMANTF_CONTAINER_REGISTRY}/${TESTMANTF_CONTAINER_IMAGE}" \
      "${TESTMANTF_CONTAINER_TEST_LIB}/testmantf-tfsec-scan.bash" \
      "$destination"
  fi

  return 0
}

function testmantf_validate() {
  local case=''

  for case in $TESTMANTF_TARGETS; do
    testmantf_target_prepare "$case" &&
      testmantf_terraform_validate "$case" ||
      return $?
    testmantf_target_cleanup "$case"
  done
}

function testmantf_lint() {
  local case=''

  for case in $TESTMANTF_TARGETS; do
    testmantf_target_prepare "$case" &&
      testmantf_tflint_lint "$case" ||
      return $?
    testmantf_target_cleanup "$case"
  done
}

function testmantf_scan() {
  local case=''

  for case in $TESTMANTF_TARGETS; do
    testmantf_target_prepare "$case" &&
      testmantf_tfsec_scan "$case" ||
      return $?
    testmantf_target_cleanup "$case"
  done
}

function testmantf_initialize() {
  local verbose="$1"
  local debug="$2"
  local command="$3"
  local module="$4"
  local root="$5"

  local target=''

  [[ "$command" == "$BL64_LIB_VAR_NULL" ]] && testmantf_help && return 1

  # Set project root path
  if [[ "$root" == "$BL64_LIB_VAR_NULL" ]]; then
    TESTMANTF_LOCAL_ROOT="$(pwd)"
  else
    bl64_check_directory "$root" || return $?
    TESTMANTF_LOCAL_ROOT="$root"
  fi

  bl64_dbg_set_level "$debug" &&
    bl64_msg_set_level "$verbose" ||
    return $?

  # Set project directory structure
  TESTMANTF_LOCAL_TMP="${TESTMANTF_LOCAL_ROOT}/.tmp"
  TESTMANTF_LOCAL_TEST="${TESTMANTF_LOCAL_ROOT}/test"
  TESTMANTF_LOCAL_TEST_TERRAFORM="${TESTMANTF_LOCAL_TEST}/terraform"

  bl64_check_directory "$TESTMANTF_LOCAL_TEST" &&
    bl64_check_directory "$TESTMANTF_LOCAL_TEST_TERRAFORM" &&
    bl64_fs_create_dir "$TESTMANTF_LOCAL_TMP_MODE" "$BL64_LIB_DEFAULT" "$BL64_LIB_DEFAULT" "$TESTMANTF_LOCAL_TMP" ||
    return $?

  # Identify test cases
  if [[ "$module" == 'all' ]]; then
    TESTMANTF_TARGETS="$(cd "$TESTMANTF_LOCAL_TEST_TERRAFORM" && "$BL64_FS_CMD_LS")" && [[ -n "$TESTMANTF_TARGETS" ]]
    bl64_check_alert_failed $? 'unable to identify test cases. Test repository seems to be empty.' || return $?
  else
    TESTMANTF_TARGETS="$module"
  fi

  if [[ "$TESTMANTF_CONTAINER_ON" == "$BL64_LIB_VAR_ON" ]]; then
    bl64_cnt_setup || return $?
  fi

  return 0
}

function testmantf_help() {
  bl64_msg_show_usage \
    '<-v|-l|-s> [-o] [-c Case] [-p Project] [-x Terraform] [-y TFLint] [-z TFSec] [-V Verbose] [-D Debug] [-h]' \
    'Test Terraform modules' \
    '
    -v          : Validate code (terraform validate)
    -l          : Lint code (tflint)
    -s          : Security check code (tfsec)
    ' '
    -h          : Show help
    -o          : Container mode
    ' "
    -c Case     : module name. Must exist under test/terraform. Default: all
    -p Project  : full path to the project. Default: PWD
    -x Terraform: full path where the terraform binary is. Default: autodetec
    -y TFLint   : full path where the tflint binary is. Default: /usr/local/bin
    -z TFSec    : full path where the tfsec binary is. Default: /usr/local/bin
    -V Verbose  : Set verbosity level. Format: one of BL64_MSG_VERBOSE_*
    -D Debug    : Enable debugging mode. Format: one of BL64_DBG_TARGET_*
    "
}
