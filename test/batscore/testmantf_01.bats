setup() {
  . "$TESTMANSH_TEST_BATSCORE_SETUP"
}

@test "CLI: no args" {
  run "$DEVTMTF_BUILD_FULL_PATH"
  assert_failure
}

@test "CLI: -h" {
  run "$DEVTMTF_BUILD_FULL_PATH" -h
  assert_success
}
