@test "testing kustomize build nginx-config" {
  cd examples/nginx-config
  furyctl install
  kustomize build
  rm -rf vendor
}
@test "testing kustomize build nginx-default-ssl-certificate" {
  cd examples/nginx-default-ssl-certificate
  furyctl install
  kustomize build
  rm -rf vendor
}
@test "testing kustomize build nginx-ldap-auth" {
  cd examples/nginx-ldap-auth
  furyctl install
  kustomize build
  rm -rf vendor
}
