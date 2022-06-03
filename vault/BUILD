load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")
load('//:versions.bzl', 'VAULT_VERSION')

package(default_visibility = ["//visibility:public"])

container_image(
    name = "image",
    base = "@base_image//image",
    creation_time = "0",
    visibility = ["//visibility:public"],
)

container_push(
    name = "push_image",
    format = "Docker",
    image = ":image",
    registry = "index.docker.io",
    repository = "alex202/vault",
    tag = VAULT_VERSION,
    skip_unchanged_digest = True,
    visibility = ["//visibility:public"],
)

genrule(
  name = "myproject",
  cmd = "printenv > $@",
  outs = ["envs.txt"]
)

genrule(
  name = "build",
  srcs = ["Dockerfile"],
  cmd = "tar -czh . | docker build -q -t alex202/vault:" + VAULT_VERSION + " --build-arg VERSION="+ VAULT_VERSION + " -f vault/Dockerfile - > $@",
  outs = ["vaultsha.txt"]
)


