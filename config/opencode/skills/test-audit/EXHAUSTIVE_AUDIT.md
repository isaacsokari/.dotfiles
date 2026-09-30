# Exhaustive subsystem audit

Use this workflow when the requested scope covers a subsystem's entire test
surface. The value bar and evidence requirements in [SKILL.md](SKILL.md) apply
throughout. Keep a working ledger so a long audit can resume without guessing.

## 1. Inventory and baseline

Record the starting revision and relevant working-tree changes. Inventory every
owned test file, shared-boundary case, fixture, and integration scenario. Group
them by production owner; record each group's baseline command and result,
including unavailable environments and existing failures.

Done when every in-scope test belongs to an owner and has a baseline status.

## 2. Classify every declaration

Read each test and production owner in full. Give every declaration a ledger
entry: retain, repair, consolidate, or delete, with the contract, credible
failure, and evidence. Split parameter rows when they warrant different
decisions. Mark uncertainty for follow-up rather than treating it as redundancy.

Done when every declaration is accounted for, including implicit assertions
and shared tests outside the subsystem's directory.

## 3. Plan by contract

Review the ledger for redundant layers. Name the keeper for each contract,
unique assertions to transfer, files to retire, and production or support seams
that can disappear. Keep separate layers when they catch distinct risks.

Done when every proposed deletion has a keeper or a supported no-contract
explanation, and all uncertain entries have a resolution or explicit deferral.

## 4. Cut over and review preservation

Apply one owner-sized batch at a time using the main skill's edit and validation
steps. Update the ledger as decisions change. Review removed assertions against
the retained suites, focusing on contracts that might lose their only proof.
For repaired or transferred regressions, use a control or targeted mutation to
prove the keeper detects the failure.

Done when all planned batches are applied, preservation gaps are resolved, and
affected keepers pass with temporary mutations restored.

## 5. Reconcile and hand off

If the base changed during the audit, examine newly added or modified tests and
give each new contract a home. Follow the repository's integration policy and
rerun the subsystem suite on the final tree. Account for baseline product bugs
separately from audit regressions.

Hand off the ledger, keeper map, deferred candidates, validation evidence, and
production versus test/support diff size. Claim an exhaustive audit only when
the inventory and final ledger reconcile; name any unexamined scope.
