#!/usr/bin/env bash

source "${TESTMANTF_CONTAINER_LIB}/bashlib64.bash" || exit 1

#
# Variables
#

declare case="$1"
declare tfsec_bin='/usr/local/bin/tfsec'

#
# Main
#

bl64_msg_all_enable_verbose

cd "$case" &&
  "$tfsec_bin" \
    --concise-output \
    --tfvars-file terraform.tfvars \
    . &&
  bl64_fs_run_chmod -R '0777' '.tfsec'
