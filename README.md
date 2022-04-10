# Script: testmantf

## Overview

Test manager for Terraform scripts.

The **testmantf** tool provides a simple management interface for testing terraform scripts either using native Terraform or inside a purpose-build container.

Supported features:

- Run test inside container using **podman**
- Run test using native **terraform**
- Test terraform scripts
  - terraform init
  - terraform apply
  - terraform show
- Clean-up test environment
- Isolate test-case's runtime environment from eachother:
  - logs
  - tfstate
  - tflock

Default test cases directory structure:

| Shell variable  | Default value               | Purpose                   |
| --------------- | --------------------------- | ------------------------- |
| TESTMANTF_ROOT  | `.`                         | Project directory         |
| TESTMANTF_VAR   | `<TESTMANTF_ROOT>/.var`     | Terraform variable data   |
| TESTMANTF_CACHE | `<TESTMANTF_ROOT>/.cache`   | Terraform cache           |
| TESTMANTF_TEST  | `<TESTMANTF_ROOT>/test`     | Test cases root directory |
|                 | `<TESTMANTF_TEST>/<MODULE>` | Terraform test case       |

## Usage

```text
Usage: testmantf <-t|-d|-s|-c> -n Module [-i Image] [-o] [-D Level] [-h]

Test Terraform modules

Commands

    -t       : Run module test (terraform init, terraform apply)
    -d       : Destroy module test infrastructure (terraform destroy)
    -s       : Show current test infrastructure (terraform show)
    -c       : Clean test environment

Flags

    -o       : Enable container mode (run actions inside a container)
    -h       : Show help

Parameters

    -n Module: module name
    -i Image : container image name (default: docker.io/hashicorp/terraform:latest)
    -D Level : debug level
```

### Test script with terraform apply

```shell
testmantf -t -o -n provider
```

## Deployment

### Requirements

- Bash >= v4
- Container test
  - Podman >= v3
- Native test
  - Terraform >= 1

### Installation

Download **testmantf** from the source GitHub repository:

```shell
curl -O https://raw.githubusercontent.com/serdigital64/testmantf/main/testmantf
chmod 0755 testmantf
# Optional: move to searchable path
mv testmantf ~/.local/bin
```

## Contributing

Help on implementing new features and maintaining the code base is welcomed.

[Guidelines](CONTRIBUTING.md)
[Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md)

### License

[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.txt)

### Author

- [SerDigital64](https://serdigital64.github.io/)
