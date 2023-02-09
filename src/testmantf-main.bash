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
while getopts ':vlsoc:x:y:z:V:D:h' testmantf_option; do
  case "$testmantf_option" in
  v)
    testmantf_command='testmantf_validate'
    testmantf_command_tag='validate with terraform'
    ;;
  l)
    testmantf_command='testmantf_lint'
    testmantf_command_tag='lint with tflint'
    ;;
  s)
    testmantf_command='testmantf_scan'
    testmantf_command_tag='scan with tfsec'
    ;;
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
testmantf_initialize "$testmantf_verbose" "$testmantf_debug" "$testmantf_command" \
  "$testmantf_case" "$testmantf_root" ||
  exit 1

bl64_msg_show_batch_start "$testmantf_command_tag"
case "$testmantf_command" in
'testmantf_validate') "$testmantf_command" ;;
'testmantf_lint') "$testmantf_command" ;;
'testmantf_scan') "$testmantf_command" ;;
*) bl64_check_alert_parameter_invalid "$testmantf_command" ;;
esac
testmantf_status=$?

bl64_msg_show_batch_finish $testmantf_status "$testmantf_command_tag"
exit $testmantf_status
