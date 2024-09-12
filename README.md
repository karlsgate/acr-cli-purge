# GitHub Action to Clean Up Azure Container Registry (ACR)

This action is designed to use the [Azure CLI ACR](https://docs.microsoft.com/en-us/cli/azure/acr) to clean up images from an Azure Container Registry (ACR) based on certain conditions, such as tag age, patterns, and untagged images.

## Usage

### Example

Place this in a `.yml` file within your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

```yaml
name: Clean Up ACR
on:
  push:
    branches:
      - master
jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ACR Purge
        uses: karlsgate/acr-cli-purge@v1
        with:
          registry: myRegistry
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
          repo: 'myrepo'
          tag_regex: 'v[0-9]+'
          repo_regex: 'myrepo'
          ago: '30d'
          keep: '5'
          dry_run: true
          delete_untagged: true
```

### Required Inputs

| Key             | Description                                                                    |
|-----------------|--------------------------------------------------------------------------------|
| `registry`      | The name of the Azure Container Registry (ACR) to clean up                      |
| `username`      | The username to authenticate with the Azure Container Registry                  |
| `password`      | The password to authenticate with the Azure Container Registry                  |

### Optional Inputs

| Key               | Description                                                                                                  |
|-------------------|--------------------------------------------------------------------------------------------------------------|
| `repo`            | The name of the ACR repository to clean up (default: 'all')                                                  |
| `tag_regex`       | A regex pattern to match tags for deletion (default: `.*`)                                                   |
| `repo_regex`      | A regex pattern to match repositories for deletion (only used if `repo` is not specified; default: `.*`)     |
| `ago`             | The time granularity to retain tags (default: 30d which is 30 days)                                          |
| `keep`            | The number of tags to keep, even if they meet the deletion criteria (default: 3)                             |
| `dry_run`         | If set to `true`, the action will only print the tags that would be deleted (default: `false`)               |
| `delete_untagged` | If set to `true`, the action will delete untagged manifests (default: `false`)                               |

## License

This project is distributed under the [MIT License](LICENSE).
