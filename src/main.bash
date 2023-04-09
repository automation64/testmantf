#
# Main
#

declare testmantf_status=1
declare testmantf_debug="$BL64_DBG_TARGET_NONE"
declare testmantf_verbose="$BL64_MSG_VERBOSE_APP"
declare testmantf_command="$BL64_VAR_NULL"
declare testmantf_option=''
declare testmantf_case='all'
declare testmantf_root="$BL64_VAR_NULL"

(($# == 0)) && testmantf_help && exit 1
while getopts ':vlsqoc:x:y:z:V:D:h' testmantf_option; do
  case "$testmantf_option" in
  v) testmantf_command='testmantf_validate' ;;
  l) testmantf_command='testmantf_lint' ;;
  s) testmantf_command='testmantf_scan' ;;
  q) testmantf_command='testmantf_open' ;;
  c) testmantf_case="$OPTARG" ;;
  o) TESTMANTF_CONTAINER_ON="$BL64_VAR_ON" ;;
  x) TESTMANTF_CMD_TERRAFORM="$BL64_VAR_ON" ;;
  y) TESTMANTF_CMD_TFLINT="$BL64_VAR_ON" ;;
  z) TESTMANTF_CMD_TFSEC="$BL64_VAR_ON" ;;
  V) testmantf_verbose="$OPTARG" ;;
  D) testmantf_debug="$OPTARG" ;;
  h) testmantf_help && exit 0 ;;
  *) testmantf_help && exit 1 ;;
  esac
done
bl64_dbg_set_level "$testmantf_debug" && bl64_msg_set_level "$testmantf_verbose" || exit $?
testmantf_initialize "$testmantf_command" "$testmantf_case" "$testmantf_root" || exit $?

bl64_msg_show_batch_start "$testmantf_command"
case "$testmantf_command" in
'testmantf_validate') "$testmantf_command" ;;
'testmantf_lint') "$testmantf_command" ;;
'testmantf_scan') "$testmantf_command" ;;
'testmantf_open') "$testmantf_command" ;;
*) bl64_check_alert_parameter_invalid "$testmantf_command" ;;
esac
testmantf_status=$?

bl64_msg_show_batch_finish $testmantf_status "$testmantf_command"
exit $testmantf_status
