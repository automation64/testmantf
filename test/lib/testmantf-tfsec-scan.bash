#!/usr/bin/env bash

source "${TESTMANTF_CONTAINER_LIB}/bashlib64.bash" || exit 1

#
# Variables
#

declare case="$1"
declare tfsec_bin='/usr/local/bin/tfsec'
declare tfsec_out="${case}/.tfsec"

#
# Main
#

bl64_msg_all_enable_verbose

cd "$case" &&
  "$tfsec_bin" \
    --concise-output \
    --tfvars-file terraform.tfvars \
    .

[[ -f "$tfsec_out" ]] && bl64_fs_fix_permissions '0666' '0777' "$tfsec_out"

exit 0
