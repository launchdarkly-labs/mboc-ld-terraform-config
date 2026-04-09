# MB.OC — LaunchDarkly Adoption Plan

Phased plan to operationalize LaunchDarkly adoption across the MB.OC organization, expanding from the access/authorization framework defined in this repository.

> **How to use this plan:** Fill in the `Owner` column with the responsible person or team. Update `Status` as work progresses. Adjust `Target` dates to match your actual kickoff date — timelines below are expressed as relative weeks from project start.

---

## Phase 1: Platform Governance

Operationalize the access and authorization framework so that every MB.OC team has the right level of access from day one.

| # | Task | Description | Target | Status | Owner |
|---|------|-------------|--------|--------|-------|
| 1.1 | **Finalize organizational hierarchy** | Replace the placeholder Projects and Products in `terraform.tfvars` with the real MB.OC structure (see [Customization](README.md#customization)). Decide which projects are `managed` by Terraform vs. managed via the UI. | Week 1 | Not started | |
| 1.2 | **Apply Terraform configuration** | Run `terraform plan` and `terraform apply` to provision Custom Roles, Teams, and Views in the production LD account aligned with the actual MB.OC organization. Verify resources in the LD UI. | Week 1 | Not started | |
| 1.3 | **Provision LD access for pilot teams** | Invite members of the selected pilot team(s) to the LaunchDarkly account so they have access to the platform. | Week 1–2 | Not started | |
| 1.4 | **Assign Custom Roles and Teams** | Assign each member the appropriate Custom Role (LD Admins, Developers, Maintainers, Secrets Managers) based on their job function and place them in the corresponding LD Teams to scope their view-based access. | Week 1–2 | Not started | |
| 1.5 | **Validate access controls** | Have representatives from different roles verify they can see and manage only the resources within their scope, and confirm they cannot access resources outside it. | Week 2 | Not started | |

---

## Phase 2: Technical Foundation

Lay the technical groundwork: context design, SDK integration, abstractions, and integration dependencies.

| # | Task | Description | Target | Status | Owner |
|---|------|-------------|--------|--------|-------|
| 2.1 | **Finalize LD context design** | Define the context kinds (e.g. `user`, `device`, `organization`, `service`) and their attributes that the MB.OC services will evaluate flags against. Document the schema and agree on it with the architects. | Week 2–3 | Not started | |
| 2.2 | **Design SDK wrapper / abstraction layer** | Evaluate whether a thin wrapper class around the LD SDK is needed (e.g. for consistent context construction, default flag values, logging, or testability). If yes, define the interface and implement it. | Week 3 | Not started | |
| 2.3 | **Implement SDK in the pilot service** | Integrate the LaunchDarkly SDK (or the wrapper from 2.2) into the selected pilot service. Configure the SDK client with the context design from 2.1. Validate connectivity in a non-critical environment. | Week 3–4 | Not started | |
| 2.4 | **Map required integrations and dependencies** | Identify any integrations the SDK or rollout process depends on (e.g. observability/APM, CI/CD pipelines, data platforms, SSO/SCIM for member provisioning). Document blockers or prerequisites. | Week 3 | Not started | |

---

## Phase 3: Guidelines & Enablement

Establish conventions and internal documentation so teams can adopt LD consistently.

| # | Task | Description | Target | Status | Owner |
|---|------|-------------|--------|--------|-------|
| 3.1 | **Define flag naming conventions** | Agree on a naming standard for feature flags (e.g. `<product>.<scope>.<name>`). Document examples and anti-patterns. | Week 3–4 | Not started | |
| 3.2 | **Define tagging strategy** | Establish a tagging taxonomy for flags (e.g. by product, team, release, flag purpose). Tags will be used for filtering, reporting, and view-scoping. | Week 3–4 | Not started | |
| 3.3 | **Define flag types and hierarchy** | Document the different categories of flags the organization will use (e.g. release toggles, ops toggles, experiment toggles, permission toggles, long-lived config flags) and when to use each. | Week 4 | Not started | |
| 3.4 | **Document flag lifecycle** | Define the end-to-end lifecycle of a flag: creation, review/approval, progressive rollout, completion, archival, and code removal. Include ownership at each stage. | Week 4 | Not started | |
| 3.5 | **Clarify ownership across the release cycle** | Document who is responsible for what: who creates the flag, who approves targeting changes in critical environments, who monitors the rollout, and who cleans up after the flag is fully rolled out. | Week 4–5 | Not started | |
| 3.6 | **Create internal developer guidelines** | Write a developer-facing guide covering: SDK initialization, context construction, flag evaluation best practices, error handling, default values, local development workflow, and testing with flags. | Week 4–5 | Not started | |

---

## Phase 4: Pilot Execution

Select the pilot team, enable them, and run the first LaunchDarkly-powered progressive release.

| # | Task | Description | Target | Status | Owner |
|---|------|-------------|--------|--------|-------|
| 4.1 | **Select and confirm pilot team(s)** | Choose the pilot Product team(s)/service(s). Ideal candidate: a team with with straightforward implementation and an upcoming release that benefits from progressive rollout. | Week 4 | Not started | |
| 4.2 | **Conduct pilot team enablement session** | Run a hands-on workshop with the pilot team: creating flags, evaluating them in code, targeting contexts, progressive rollout mechanics, and using the sandbox for testing. | Week 5 | Not started | |
| 4.3 | **Create feature flags for pilot release** | Create the feature flags for the pilot release in the pilot service's View. Apply the naming conventions, tagging strategy, and flag types defined in Phase 3. | Week 5 | Not started | |
| 4.4 | **Define rollout strategy** | Design the progressive rollout plan: rollout stages (e.g. internal users -> 5% -> 25% -> 100%), success/health metrics to gate each stage, and rollback criteria. | Week 5–6 | Not started | |
| 4.5 | **Execute progressive rollout** | Roll out the pilot feature using LD percentage-based targeting or context segments. Monitor at each stage before advancing. | Week 6–7 | Not started | |
| 4.6 | **Collect feedback and retrospective** | Gather feedback from the pilot team on: SDK integration experience, wrapper usability, LD UI, access model, conventions, and rollout workflow. Hold a retrospective. Document lessons learned and refine guidelines. | Week 7–8 | Not started | |

---

## Phase 5: Scale Adoption Across MB.OC

Extend LaunchDarkly adoption to additional teams across the MB.OC organization, applying lessons from the pilot.

| # | Task | Description | Target | Status | Owner |
|---|------|-------------|--------|--------|-------|
| 5.1 | **Prioritize next wave of teams** | Based on pilot learnings, identify and prioritize the next Product teams to onboard. Consider factors like upcoming releases, team readiness, and business impact. | TBD | Not started | |
| 5.2 | **Onboard additional teams** | Repeat the enablement process (Phase 4) for each new team: add members to LD Teams, conduct enablement sessions, assist with SDK integration, and support their first progressive release. | TBD | Not started | |
| 5.3 | **Audit and migrate existing flags** | Inventory any feature flags, config toggles, or environment-based switches that currently exist outside of LD across MB.OC services. Migrate relevant ones to LD under the appropriate Views. | TBD | Not started | |
| 5.4 | **Establish flag hygiene practices** | Set up a recurring review cadence (e.g. monthly) to archive completed flags, remove stale flags from code, and audit flag usage across teams. | TBD | Not started | |
| 5.5 | **Set up CI/CD integration** | Configure [LD Code References](https://docs.launchdarkly.com/integrations/code-references) in CI pipelines to track where flags are used in code. Helps with flag cleanup and auditability. | TBD | Not started | |
| 5.6 | **Operationalize Terraform config** | Consider adding a [remote backend](https://developer.hashicorp.com/terraform/language/backend) for shared state management. Establish a process for updating the hierarchy as new Projects/Products are added to MB.OC. | TBD | Not started | |

---

## Summary Timeline

```
Week 1–2    Phase 1: Platform Governance (hierarchy, roles, teams, access)
Week 2–4    Phase 2: Technical Foundation (context design, SDK, integrations)
Week 3–5    Phase 3: Guidelines & Enablement (conventions, lifecycle, docs)
Week 4–8    Phase 4: Pilot Execution (enablement, rollout, retrospective)
TBD         Phase 5: Scale Adoption (onboard remaining MB.OC teams)
```

> **Note:** Phases overlap intentionally — conventions work (Phase 3) can begin in parallel with SDK integration (Phase 2), and pilot team selection (Phase 4) can start once the technical foundation is taking shape.
