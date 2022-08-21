setup() {
  . "$TESTMANTF_TEST_BATSCORE_SETUP"
}

@test "CLI: no args" {
  run "$DEVTMTF_BUILD_TARGET"

  assert_failure
}

@test "CLI: -h" {
  run "$DEVTMTF_BUILD_TARGET" -h
  assert_success
}
