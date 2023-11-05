setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    nuv util kube import FILE=test-olaris/aks.kubeconfig NAME=aks
    nuv util kube import FILE=test-olaris/eks.kubeconfig NAME=eks
    export NO_COLOR=1
}

@test "info" {
    run nuv -info
    assert_line "NUV_ROOT: /root/olaris"
    assert_success
}
