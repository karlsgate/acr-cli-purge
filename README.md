# GitHub Action to Clean Up Azure Container Registry (ACR)

This action is designed to use the [Azure CLI ACR](https://github.com/Azure/acr-cli) to clean up images from an Azure Container Registry (ACR) based on certain conditions, such as tag age, patterns, and untagged manifests.

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
      - name: Checkout
        uses: actions/checkout@v4

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
| Key    | Description    |
|----|----|
| `repo`    | The name of the ACR repository to clean up (default: 'all')    |
| `tag_regex`    | A regex pattern to match tags for deletion (default: `.*`). This is an inclusive filter, meaning it will delete tags that match the pattern. For example, `^v[0-9]+\.[0-9]+\.[0-9]+$` would match semantic version tags like 'v1.2.3'. |
| `repo_regex`    | A regex pattern to match repositories for deletion (only used if `repo` is not specified; default: `.*`). This is an inclusive filter, meaning it will delete repositories that match the pattern. For example, `^myapp-.*$` would match repositories starting with 'myapp-'. |
| `ago`    | The time granularity to retain tags (default: 30d). This flag specifies how far back in time to consider tags for deletion. Tags created before this time will be eligible for deletion. The duration string follows Go-style formatting, which is a possibly signed sequence of decimal numbers with an optional fraction and a unit suffix. Valid units are: ns (nanoseconds), us or µs (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), and d (days). |
|    | Examples: 30d for 30 days, 2h45m for 2 hours and 45 minutes, 1.5h for 1.5 hours.   |
| `keep`    | The number of most recently created tags to retain, even if they meet the deletion criteria (default: 3). This ensures that a minimum number of recent tags are always kept, regardless of their age or pattern matching. |
| `dry_run`    | If set to `true`, the action will only print the tags that would be deleted without actually deleting them (default: `false`)    |
| `delete_untagged` | If set to `true`, the action will delete untagged manifests (default: `false`)    |

### Usage examples

Here are some examples of how different combinations of flags work together:

#### Example 1: Basic Cleanup

```yaml
- uses: karlsgate/acr-cli-purge@v1
  with:
    registry: myRegistry
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    repo: 'myapp'
    ago: '30d'
    keep: '5'
```

This configuration will:
- Target the 'myapp' repository
- Delete tags older than 30 days
- Always keep at least 5 tags, even if they're older than 30 days

#### Example 2: Cleanup with Tag Pattern

```yaml
- uses: karlsgate/acr-cli-purge@v1
  with:
    registry: myRegistry
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    repo: 'myapp'
    tag_regex: 'v[0-9]+\.[0-9]+\.[0-9]+'
    ago: '90d'
    keep: '10'
```

This configuration will:
- Target the 'myapp' repository
- Only consider tags matching the pattern 'v\d+\.\d+\.\d+' (e.g., v1.2.3)
- Delete matching tags older than 90 days
- Always keep at least 10 tags that match the pattern, even if they're older than 90 days

#### Example 3: Multi-Repository Cleanup

```yaml
- uses: karlsgate/acr-cli-purge@v1
  with:
    registry: myRegistry
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    repo_regex: 'dev-.*'
    tag_regex: 'build-[0-9]+'
    ago: '7d'
    keep: '3'
    delete_untagged: true
```

This configuration will:
- Target all repositories starting with 'dev-'
- Only consider tags matching the pattern 'build-\d+' (e.g., build-123)
- Delete matching tags older than 7 days
- Always keep at least 3 tags in each repository that match the criteria
- Delete untagged manifests in the matching repositories

#### Example 4: Aggressive Cleanup with Safeguards

```yaml
- uses: karlsgate/acr-cli-purge@v1
  with:
    registry: myRegistry
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    repo: 'all'
    tag_regex: '.*'
    ago: '1d'
    keep: '20'
    dry_run: true
```

This configuration will:
- Target all repositories in the registry
- Consider all tags for deletion
- Simulate deleting tags older than 1 day
- Always keep at least 20 tags in each repository
- Run in dry-run mode to prevent actual deletions

#### Example 5: Cleanup of Specific Version Pattern

```yaml
- uses: karlsgate/acr-cli-purge@v1
  with:
    registry: myRegistry
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    repo: 'myapp'
    tag_regex: 'v1\.[0-9]+\.[0-9]+'
    ago: '180d'
    keep: '5'
```

This configuration will:
- Target the 'myapp' repository
- Only consider tags matching the pattern 'v1\.\d+\.\d+' (e.g., v1.2.3, v1.10.0)
- Delete matching tags older than 180 days
- Always keep at least 5 tags that match the pattern, even if they're older than 180 days


## License

This project is distributed under the [MIT License](LICENSE).
