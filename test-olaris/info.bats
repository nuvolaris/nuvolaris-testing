setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    export NO_COLOR=1
}

@test "info" {
    run nuv -info
    assert_line "NUV_ROOT: /root/olaris"
    assert_success
}