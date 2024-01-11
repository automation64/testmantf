# Script: testmantf

## Overview

The **testmantf** tool provides a simple management interface for testing terraform scripts.

Supported features:

- Run test inside container using docker compatible container engine:
  - docker
  - podman
- Run test using local tools
- Test methods / tools:
  - validate: terraform
  - security scan: tfsec
  - linter: tflint
- Clean-up test environment
- Isolate test-case's runtime environment from each other

## Usage

```text
Usage: testmantf <-v|-l|-s|-q> [-o] [-c Case] [-p Project] [-x Terraform] [-y TFLint] [-z TFSec] [-V Verbose] [-D Debug] [-h]

Test Terraform modules

Commands

    -v          : Validate code (terraform validate)
    -l          : Lint code (tflint)
    -s          : Security check code (tfsec)
    -q          : Open testing container

Flags

    -h          : Show help
    -o          : Container mode

Parameters

    -c Case     : module name. Must exist under test/terraform. Default: all
    -p Project  : full path to the project. Default: PWD
    -x Terraform: full path where the terraform binary is. Default: autodetec
    -y TFLint   : full path where the tflint binary is. Default: /usr/local/bin
    -z TFSec    : full path where the tfsec binary is. Default: /usr/local/bin
    -V Verbose  : Set verbosity level. Format: one of BL64_MSG_VERBOSE_*
    -D Debug    : Enable debugging mode. Format: one of BL64_DBG_TARGET_*
```

## Deployment

### Requirements

- Bash >= v4
- Container test
  - Podman >= v3
  - Docker
- Local test
  - Terraform >= 1
  - TFSec
  - TFLint

### Installation

Download **testmantf** from the source GitHub repository:

```shell
curl -O https://raw.githubusercontent.com/automation64/testmantf/main/testmantf
chmod 0755 testmantf
# Optional: move to searchable path
mv testmantf ~/.local/bin
```

## Contributing

Help on implementing new features and maintaining the code base is welcomed.

- [Guidelines](CONTRIBUTING.md)
- [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md)

### License

[Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0.txt)

### Author

- [SerDigital64](https://github.com/serdigital64)
