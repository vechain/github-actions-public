# Reusable GitHub Actions (Public)

![Zizmor Checks](https://github.com/vechain/github-actions-public/actions/workflows/scan-workflows.yaml/badge.svg?branch=main&event=push)
![Action Lint](https://github.com/vechain/github-actions-public/actions/workflows/action-lint.yaml/badge.svg?branch=main&event=push)

Repository containing reusable GitHub Actions workflows for public repositories.

## Available Workflows

This repository provides the following reusable workflows:

1. **[Slither Analysis](#slither-analysis)** - Static analysis for Solidity smart contracts
2. **[Zizmor Workflow Scanner](#zizmor-workflow-scanner)** - Security scanner for GitHub Actions workflows
3. **[Action Lint](#action-lint)** - Validation and linting for GitHub Actions workflows
4. **[Documentation Update](#documentation-update)** - Automatic README updates on release
5. **[Validate PR Label](#validate-pr-label)** - Ensures semantic versioning labels on pull requests
6. **[Semantic Versioning](#semantic-versioning)** - Creates and pushes version tags after a merged PR
7. **[Infracost Check](#infracost-check)** - Terraform cost estimates on pull requests

## How to Use

### Basic Setup

1. Create a workflow in your repository (e.g., `.github/workflows/security-checks.yaml`)

2. Reference the workflows from this repository:

```yaml
name: Security Checks
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  zizmor:
    uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@b3ab84727d2c8fe86a6a7ce6963c82486afbaa49
    secrets:
      ZIZMOR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
  actionlint:
    uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@b3ab84727d2c8fe86a6a7ce6963c82486afbaa49
```

> ⚠️ **IMPORTANT:** For production use, it's **highly recommended** to pin to a specific commit SHA or release tag instead of `@main` to ensure consistency and avoid potential issues.

## Workflows Documentation

### Slither Analysis

Static analysis tool for Solidity smart contracts that detects vulnerabilities and code quality issues.

**Workflow:** `.github/workflows/slither.yaml`

#### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `target` | false | `packages/contracts/` | Directory containing Solidity contracts |
| `solc-version` | false | `0.8.20` | Solidity compiler version |
| `fail-on` | false | `none` | Fail on issue level (none, high, medium, low) |
| `slither-args` | false | See workflow | Additional Slither arguments |
| `sarif-file` | false | `slither-results.sarif` | Path for SARIF output file |
| `skip-change-detection` | false | `false` | Skip internal change detection |
| `env-vars` | false | `{}` | Additional environment variables (JSON format) |
| `cache` | false | `yarn` | Package manager for caching (npm, yarn, pnpm) |
| `compile-command` | false | `skip` | Command to compile contracts |
| `ignore-compile` | false | `false` | Use existing artifacts without compilation |

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `MNEMONIC` | false | Mnemonic for local environment (dummy value used if not provided) |
| `TESTNET_STAGING_MNEMONIC` | false | Mnemonic for testnet staging |
| `GALACTICA_TEST_MNEMONIC` | false | Mnemonic for Galactica test |
| `VECHAIN_URL_DEVNET` | false | VeChain devnet URL |

#### Outputs

| Output | Description |
|--------|-------------|
| `compilation-status` | Status of contract compilation |
| `slither-status` | Status of Slither analysis |
| `comment-status` | Status of PR comment posting |
| `sarif-file` | Path to generated SARIF file |
| `overall-status` | Overall workflow status |

#### Usage Examples

**Basic usage:**

```yaml
slither:
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
```

**Custom configuration:**

```yaml
slither:
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
  with:
    target: 'contracts/'
    solc-version: '0.8.19'
    fail-on: 'high'
    slither-args: '--exclude-informational --exclude-optimization'
    cache: 'npm'
    compile-command: 'npm run build:contracts'
```

**With external change detection:**

```yaml
check-changes:
  runs-on: ubuntu-latest
  outputs:
    contracts-changed: ${{ steps.changes.outputs.contracts }}
  steps:
    - uses: actions/checkout@v4
    - uses: dorny/paths-filter@v3
      id: changes
      with:
        filters: |
          contracts:
            - 'contracts/**'

slither:
  needs: check-changes
  if: needs.check-changes.outputs.contracts-changed == 'true'
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
  with:
    target: 'contracts/'
    skip-change-detection: true
```

**With custom environment variables:**

```yaml
slither:
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
  with:
    target: 'contracts/'
    env-vars: '{"NODE_ENV": "testing", "DEBUG_MODE": "false"}'
  secrets:
    MNEMONIC: ${{ secrets.MNEMONIC }}
    VECHAIN_URL_DEVNET: ${{ secrets.VECHAIN_URL_DEVNET }}
```

---

### Zizmor Workflow Scanner

Security scanner for GitHub Actions workflows that detects security issues and misconfigurations using ReviewDog for PR feedback.

**Workflow:** `.github/workflows/scan-workflows.yaml`

#### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `persona` | false | `regular` | Scan persona (regular, pedantic, auditor) |
| `min_severity` | false | `medium` | Minimum severity to report (low, medium, high) |
| `min_confidence` | false | `high` | Minimum confidence to report (informational, low, medium, high) |

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `ZIZMOR_TOKEN` | true | Personal Access Token for zizmor (can use `GITHUB_TOKEN`) |

#### Usage Examples

**Basic usage:**

```yaml
zizmor:
  uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@v.2.1.1
  secrets:
    ZIZMOR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Custom configuration:**

```yaml
zizmor:
  uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@v.2.1.1
  with:
    persona: 'auditor'
    min_severity: 'high'
    min_confidence: 'medium'
  secrets:
    ZIZMOR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Features:**

- Scans GitHub workflows with Zizmor for security issues
- Posts results as PR reviews via ReviewDog on pull requests
- Publishes GitHub Checks on non-PR events
- Generates SARIF output for code scanning integration

---

### Action Lint

Validates GitHub Actions workflow files for syntax errors, best practices, and common issues.

**Workflow:** `.github/workflows/action-lint.yaml`

#### Usage

**Basic usage:**

```yaml
actionlint:
  uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@v.2.1.1
```

**On pull requests only:**

```yaml
name: Workflow Validation
on:
  pull_request:

jobs:
  actionlint:
    uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@v.2.1.1
```

**Features:**

- Validates workflow syntax and structure
- Checks for common mistakes and anti-patterns
- Provides detailed error messages with file/line information
- Integrates with GitHub's problem matcher for inline annotations

---

### Documentation Update

Automatically updates README.md with new release tags and commit SHAs when a release is published.

**Workflow:** `.github/workflows/doc-update.yaml`

#### Usage

This workflow is triggered automatically on release events. To use it:

1. Add the workflow to your repository
2. Ensure your README.md contains version references (e.g., `v.2.1.1` and commit SHAs)
3. Create a new release

**Workflow trigger:**

```yaml
name: Update Documentation
on:
  release:
    types: [published]

jobs:
  update-docs:
    uses: vechain/github-actions-public/.github/workflows/doc-update.yaml@v.2.1.1
```

**Features:**

- Automatically updates version tags in README.md
- Updates commit SHAs to match new release
- Attempts direct push to main branch
- Creates PR if direct push fails (branch protection enabled)
- Provides detailed summary of changes

---

### Validate PR Label

Ensures every pull request has exactly one of the semantic versioning labels (`increment:major`, `increment:minor`, `increment:patch`) before merge. Optionally fails if the label is missing, or applies a default label (by default `increment:patch`) via the GitHub API.

**Workflow:** `.github/workflows/validate-pr-label.yaml`

#### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `FAIL_IF_MISSING_LABEL` | false | `false` | If `true`, the job fails when no increment label is present (forces manual labeling). |
| `DEFAULT_LABEL` | false | `increment:patch` | Label applied automatically when none is present and `FAIL_IF_MISSING_LABEL` is `false`. |

#### Usage

Call this job from a workflow that runs on `pull_request`. The calling workflow needs permission to add labels (for example `pull-requests: write`).

**Basic usage (auto-apply patch if missing):**

```yaml
name: PR labels
on:
  pull_request:
    types: [opened, synchronize, reopened, labeled, unlabeled]

jobs:
  validate-label:
    permissions:
      contents: read
      pull-requests: write
    uses: vechain/github-actions-public/.github/workflows/validate-pr-label.yaml@v.2.1.1
```

**Require explicit increment label (no auto-apply):**

```yaml
jobs:
  validate-label:
    permissions:
      contents: read
      pull-requests: read
    uses: vechain/github-actions-public/.github/workflows/validate-pr-label.yaml@v.2.1.1
    with:
      FAIL_IF_MISSING_LABEL: true
```

**Features:**

- Validates presence of `increment:major`, `increment:minor`, or `increment:patch`
- Optional automatic default label when validation-only mode is off
- Pairs with [Semantic Versioning](#semantic-versioning), which reads the same labels after merge

---

### Semantic Versioning

After a pull request is merged, creates a new Git tag in the form `v.MAJOR.MINOR.PATCH` and pushes it to the repository. The bump level is derived from PR labels (`increment:major`, `increment:minor`, `increment:patch`); if none match, patch is used. The workflow name in the YAML file is “Codebase Versioning”.

**Workflow:** `.github/workflows/semantic-versioning.yaml`

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `DEPLOY_KEY` | true | SSH private key with permission to push tags to the repository (configure the matching deploy key in repo settings). |

#### Usage

Invoke from a workflow triggered when a PR is merged (for example `pull_request` with `types: [closed]`). The reusable workflow skips work unless `github.event.pull_request.merged == true`.

**Example:**

```yaml
name: Version tag on merge
on:
  pull_request:
    types: [closed]

jobs:
  tag-release:
    if: github.event.pull_request.merged == true
    uses: vechain/github-actions-public/.github/workflows/semantic-versioning.yaml@v.2.1.1
    secrets:
      DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

**Features:**

- Reads increment intent from the same `increment:*` labels as [Validate PR Label](#validate-pr-label)
- Skips tagging if the current `HEAD` already matches the latest `v.*` tag
- Annotated tag message includes the PR title

---

### Infracost Check

Runs [Infracost](https://www.infracost.io/) on pull requests: compares a baseline cost (merge base) with the PR branch, then posts a summary comment on the PR. Intended for repositories that use Terraform (`.tf`, `.tfvars`, `.hcl`). Supports private Terraform modules via an SSH deploy key.

**Workflow:** `.github/workflows/infracost.yaml`

#### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `run-on-tf-changes-only` | false | `true` | If `true`, skip the cost job unless Terraform-related files changed (via path filters). |
| `comment_behavior` | false | `update` | How to post PR comments: `update`, `new`, `hide-and-new`, or `delete-and-new` ([docs](https://www.infracost.io/docs/features/cli_commands/#comment-on-pull-requests)). Invalid values fall back to `update`. |
| `root_path` | false | `.` | Directory passed to Infracost `--path`. |
| `exclude_path` | false | — | Optional `--exclude-path` for Infracost. |
| `terraform_var_files` | false | — | Comma-separated tfvars paths (e.g. `vars/dev.tfvars,vars/common.tfvars`). |
| `terraform_vars` | false | — | Comma-separated `key=value` pairs for `--terraform-var`. |

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `INFRACOST_API_KEY` | true | Infracost Cloud API key. |
| `TERRAFORM_SSH_KEY` | true | SSH private key used to clone private Terraform modules over SSH (`git@github.com:...`). Configure the matching deploy key or user key as appropriate. |

The workflow file only references secret **names**; values stay in GitHub Actions secrets and are not in the repository. GitHub masks registered secrets in job logs (avoid enabling debug logging that prints environment dumps). For **public** repos, workflows triggered by `pull_request` from **forks** do not receive upstream repository secrets, so outside contributors cannot run jobs that use these keys against your secrets.

#### Usage

Call only from workflows triggered by **`pull_request`** (the reusable workflow expects `github.event.pull_request`). The cost job runs on `opened` and `synchronize`; a separate job detects Terraform file changes when `run-on-tf-changes-only` is enabled.

**Example:**

```yaml
name: Infracost
on:
  pull_request:
    branches: [main]

jobs:
  infracost:
    permissions:
      contents: read
      pull-requests: write
    uses: vechain/github-actions-public/.github/workflows/infracost.yaml@v.2.1.1
    secrets:
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      TERRAFORM_SSH_KEY: ${{ secrets.TERRAFORM_SSH_KEY }}
    with:
      root_path: infra
      run-on-tf-changes-only: true
      comment_behavior: update
```

**Features:**

- Baseline checkout on the PR base ref, then checkout of the PR head for `infracost diff`
- Optional skip when no Terraform paths changed (`dorny/paths-filter`)
- `persist-credentials: false` on checkout; GitHub token used only for posting the Infracost comment

---

## Best Practices

### Pinning Versions

Always pin workflows to specific versions for security and stability:

```yaml
# ✅ Good - pinned to specific SHA
uses: vechain/github-actions-public/.github/workflows/slither.yaml@a1b2c3d4...

# ✅ Good - pinned to release tag
uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1

# ⚠️ Avoid - tracks main branch (unpredictable)
uses: vechain/github-actions-public/.github/workflows/slither.yaml@main
```

### Permissions

Configure minimal required permissions for each workflow:

```yaml
jobs:
  security-checks:
    permissions:
      contents: read
      security-events: write
      pull-requests: write
    uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
```

### Secrets Management

Use GitHub secrets for sensitive data:

```yaml
jobs:
  slither:
    uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.2.1.1
    secrets:
      MNEMONIC: ${{ secrets.MNEMONIC }}
      # ❌ Never hardcode secrets in workflows
```

---

## Contributing

Contributions are welcome! Please ensure that:

1. All workflows are tested before submission
2. Documentation is updated for new features
3. Workflows follow security best practices
4. Changes are backwards compatible when possible

---

## License

This project is licensed under [the LICENSE](LICENSE.md).

## Support

For issues, questions, or feature requests, please open an issue in this repository.
