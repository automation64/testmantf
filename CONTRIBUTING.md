# Contributing

## Development

### Environment

- Prepare dev tools
  - Install GIT
  - Install Container engine
    - Podman
- Clone GIT repository

  ```shell
  git clone https://github.com/serdigital64/testmantf
  ```

- Adjust environment variables to reflect your configuration:

  ```shell
  # Copy environment definition files from templates:
  cp dot.local .local
  cp dot.secrets .secrets
  # Review and update content for both files
  ```

- Initialize dev environment variables

  ```shell
  source bin/devtmtf-set
  ```

## Testing

## Repositories

- Project GIT repository: [https://github.com/serdigital64/testmantf](https://github.com/serdigital64/testmantf)
- Project Documentation: [https://github.com/serdigital64/testmantf](https://github.com/serdigital64/testmantf)
- Release history: [CHANGELOG](CHANGELOG.md)
