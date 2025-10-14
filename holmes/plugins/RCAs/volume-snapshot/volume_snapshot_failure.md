Summary
What happened and what was the impact?
Customers failed to take volume snapshot for HanaDB during maintenance window. https://jira.tools.sap/browse/HC01-421482 
Impact: Snapshot failed due to velero's upgrade(The open-source backup/recovery software maintained in hc-disaster-recovery)
Which productive versions are affected by this issue?
hana-snapshot-operator {
    namespace:hc-snapshot,
    deployment:hana-snapshot-operator
    microservice-version:1.0-2481.c368de3git
}
hc-disaster-recovery {
    namespace:velero,
    deployment:velero,
    microservice-version: 1.3.3-450.611596egit
    velero-version: 1.16.x
}
Was the issue caused by a new feature?
It was caused by a new feature of multi-thread backup introduced in velero 1.16.x
Five Why (Cause 1)

1. Why did the snapshot fail?

The Hana Snapshot Service (HSS) converts customer snapshot requests into equivalent Velero commands. Velero then filters irrelevant resources (Hananode CR, PVC, retained PVs) and invokes volume snapshot plugins.

In this incident, after Velero's multi-threading upgrade, the native snapshotter plugin(not csi snapshot plugin) was invoked multiple times concurrently without proper synchronization. This caused the plugin process to crash, which cascaded into a complete snapshot failure.

2. Why did the customer observe inconsistent logs across different services?

The call chain is: Customer UI/Script → Snapshot Service → Velero → Plugin → IaaS. Each component must strictly synchronize its status to ensure log consistency for customers.

Unfortunately, when the plugin crashed, it only caused the Velero backup to fail (the Velero process itself did not crash, which is part of its design). The root cause was not propagated back to the Snapshot Service.

Additionally, Velero upstream continuously introduces new status parameters. We cannot (and realistically may never be able to) guarantee that all states are strictly tracked across the entire chain.

3. Why was this promoted to canary/prod before we detected the issue?

Two factors contributed:

Previous usage pattern: We previously performed one backup per Hananode, so we didn't anticipate concurrency issues. However, we were unaware that a single Hananode could have multiple PVs in newer setups.
Test coverage gap: This feature is only exercised by actual customer usage in canary/prod environments. Our existing tests did not cover this scenario, and this type of issue can only be caught by E2E tests (unit tests and integration tests cannot guarantee this).

4. Why did root cause analysis take two days?

Two reasons:

Cross-team coordination: We needed time to coordinate investigation between two teams.
Concurrency issues are hard to reproduce: The fact that we identified the root cause within two days was only possible because we had already detected and investigated this issue beforehand. In reality, reproducing the problem, investigating it, and submitting a patch had already taken us a full week prior to this incident.

5. Why did the fix take several days?

Several factors delayed the resolution:

Cannot directly roll back: Too much time had passed, with multiple microservice versions deployed in between. Rolling back to the pre-upgrade version would lose N versions worth of updates.
New PR required for downgrade: We needed to create a new PR to downgrade the specific component, which required additional time to run through the CI/CD pipeline.
Gradual promotion process: We needed to promote the fix through each environment sequentially, starting with confirming it worked correctly in the demo landscape before proceeding.
Improvement Actions
No test for checking the use case of snapshotting volumes concurrently.
Enhance the tests: Add a multi-volume backup/recovery test with multi-volumes.
Contribute to the open-source: Two patching PR merged into master and will be released in 1.17.1 https://github.com/vmware-tanzu/velero/pull/9248 , https://github.com/vmware-tanzu/velero/pull/9281 
Align with the open-source community: Some basic functionality should be tested in their pipeline, not ours.
Customers are receiving inconsistent logs across different services
Align with teams(mainly between HSS and CSI-Tang) with the status parameters.