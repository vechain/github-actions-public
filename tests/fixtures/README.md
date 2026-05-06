# Test fixtures

These files exist solely to give the reusable workflows in `.github/workflows/`
a deterministic, minimal input on every PR. They are **not** examples of how
consumers should structure their projects.

| Subdir | Used by | What it is |
|---|---|---|
| `slither/contracts/` | `test-slither` job in `.github/workflows/test-workflows.yaml` | One trivial Solidity contract. Slither analyses it; the test passes if the workflow runs end-to-end. |
| `checkov/` | `test-checkov` | One `null_resource` Terraform graph - parses cleanly, no provider creds needed. |
| `infracost/` | `test-infracost` | One `aws_instance.t3_micro` so Infracost has a known cost line. AWS keys are placeholders; nothing is ever deployed. |

## When to update a fixture

- **Workflow gains a new required input** → add the input to the matching test
  job in `test-workflows.yaml`. Update the fixture only if the input requires
  new on-disk state.
- **Workflow's underlying tool changes** (e.g. Slither version) → no change
  needed unless the tool no longer accepts the fixture. Run the harness via
  `gh workflow run "Test reusable workflows"` to confirm.

## Negative tests (expected-failure jobs)

`test-doc-update-bad-tag` deliberately invokes `doc-update.yaml` with an
invalid `simulated_tag` so the workflow's own regex validation must reject it.
The job appears **red** in the GitHub UI when the negative case works
correctly. GitHub Actions does not allow `continue-on-error` on reusable-
workflow calls, so the only way to flip a red into a green is via the
`assert-doc-update-bad-tag-failed` follow-up job - that job is the one
included in the `required` aggregator. Branch protection should require the
`Test harness summary` check, not the workflow run status as a whole.

## Adding a new reusable workflow

1. Add a new fixture subdir here if the workflow needs on-disk state.
2. Add a new path filter and test job to `.github/workflows/test-workflows.yaml`.
3. Add the new test job to the `needs:` list of the `required` aggregator job.

## Local iteration with `act`

Some test jobs run cleanly under [`nektos/act`](https://github.com/nektos/act);
others need GitHub-hosted runners (SARIF upload, ReviewDog, real API keys).

| Job | act | Notes |
|---|---|---|
| `test-action-lint` | OK | pure linter |
| `test-checkov` | OK | filesystem-only (uses act's `--artifact-server-path` shim) |
| `test-validate-pr-label` | broken | paths-filter needs `compareCommits` API, returns no-changes under act |
| `test-slither` | partial | runs locally; SARIF upload + PR comment fail |
| `test-semantic-versioning` | partial | dry-run only |
| `test-doc-update` | partial | dry-run only |
| `test-scan-workflows` | broken | ReviewDog needs the real GitHub API |
| `test-infracost` | broken | needs real `INFRACOST_API_KEY` + base/head refs |

Quick start: `tests/test-local.sh checkov`. The wrapper supplies a synthetic
pull_request event payload (paths-filter needs `repository.default_branch`)
and starts act's built-in artifact server (`upload-artifact@v5` requires it).
