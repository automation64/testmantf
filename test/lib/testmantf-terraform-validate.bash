#!/usr/bin/env bash

source "${TESTMANTF_CONTAINER_LIB}/bashlib64.bash" || exit 1

#
# Variables
#

declare case="$1"

#
# Main
#

bl64_msg_all_enable_verbose

cd "$case" &&
  bl64_tf_setup &&
  bl64_tf_run_terraform init &&
  bl64_tf_run_terraform validate &&
  bl64_fs_run_chmod -R '0777' "$BL64_TF_DEF_PATH_RUNTIME"
