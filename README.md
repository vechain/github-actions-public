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
    uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@cf384c612d562dbc17022d23ed094751e92921e5
    secrets:
      ZIZMOR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
  actionlint:
    uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@cf384c612d562dbc17022d23ed094751e92921e5
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
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
```

**Custom configuration:**

```yaml
slither:
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
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
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
  with:
    target: 'contracts/'
    skip-change-detection: true
```

**With custom environment variables:**

```yaml
slither:
  uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
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

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `ZIZMOR_TOKEN` | true | Personal Access Token for zizmor (can use `GITHUB_TOKEN`) |

#### Usage Examples

**Basic usage:**

```yaml
zizmor:
  uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@v.1.0.0
  secrets:
    ZIZMOR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Custom configuration:**

```yaml
zizmor:
  uses: vechain/github-actions-public/.github/workflows/scan-workflows.yaml@v.1.0.0
  with:
    persona: 'auditor'
    min_severity: 'high'
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
  uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@v.1.0.0
```

**On pull requests only:**

```yaml
name: Workflow Validation
on:
  pull_request:

jobs:
  actionlint:
    uses: vechain/github-actions-public/.github/workflows/action-lint.yaml@v.1.0.0
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
2. Ensure your README.md contains version references (e.g., `v.1.0.0` and commit SHAs)
3. Create a new release

**Workflow trigger:**

```yaml
name: Update Documentation
on:
  release:
    types: [published]

jobs:
  update-docs:
    uses: vechain/github-actions-public/.github/workflows/doc-update.yaml@v.1.0.0
```

**Features:**

- Automatically updates version tags in README.md
- Updates commit SHAs to match new release
- Attempts direct push to main branch
- Creates PR if direct push fails (branch protection enabled)
- Provides detailed summary of changes

---

## Best Practices

### Pinning Versions

Always pin workflows to specific versions for security and stability:

```yaml
# ✅ Good - pinned to specific SHA
uses: vechain/github-actions-public/.github/workflows/slither.yaml@a1b2c3d4...

# ✅ Good - pinned to release tag
uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0

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
    uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
```

### Secrets Management

Use GitHub secrets for sensitive data:

```yaml
jobs:
  slither:
    uses: vechain/github-actions-public/.github/workflows/slither.yaml@v.1.0.0
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
