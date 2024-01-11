# Contributing

## Prepare Development Environment

- Prepare dev tools
  - Install GIT
  - Install Container engine
    - Podman, Docker
- Clone GIT repository

  ```shell
  git clone https://github.com/automation64/testmantf
  ```

- Adjust environment variables to match your configuration:

  - Copy environment definition files from templates:

  ```shell
  cp dot.local .local
  cp dot.secrets .secrets
  ```

  - Review and update content for both files to match your environment

- Download dev support scripts

  ```shell
  ./bin/dev-lib
  ```

## Update source code

- Add/Edit source code in: `src/`

## Build

- Build distributable script

  ```shell
  ./bin/dev-build
  ```

## Test source code

- Add/update test-cases in: `test/`

## Repositories

- Project GIT repository: [https://github.com/automation64/testmantf](https://github.com/automation64/testmantf)
- Project Documentation: [https://github.com/automation64/testmantf](https://github.com/automation64/testmantf)
- Release history: [CHANGELOG](CHANGELOG.md)
