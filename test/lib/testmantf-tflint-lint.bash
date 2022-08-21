#!/usr/bin/env bash

source "${TESTMANTF_CONTAINER_LIB}/bashlib64.bash" || exit 1

#
# Variables
#

declare case="$1"
declare tflint_bin='/usr/local/bin/tflint'

#
# Main
#

bl64_msg_all_enable_verbose

cd "$case" &&
  "$tflint_bin" \
    --module \
    --loglevel=warn \
    .
