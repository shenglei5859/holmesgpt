## Diagnostic Runbook for Volume Snapshot Failures in HanaDB

### 1. Service Dependency Chain

[Source: "The call chain is: Customer UI/Script → Snapshot Service → Velero → Plugin → IaaS."]

#### Components & Observability Points
- **Customer UI/Script**
  - **Namespace / Pod pattern**: User-facing, non-specific
  - **Log locations**: User scripting logs
  - **Metrics / Traces to check**: Request initiation, errors on failure to receive response from next service

- **Snapshot Service (Hana Snapshot Service)**
  - **Namespace / Pod pattern**: `hc-snapshot`, `hana-snapshot-operator`
  - **Log locations**: Application logs within namespace
  - **Metrics / Traces to check**: Conversion success logs, hand-off to Velero, synchronization status logs

- **Velero**
  - **Namespace / Pod pattern**: `velero`, `velero`
  - **Log locations**: Velero application and plugin logs
  - **Metrics / Traces to check**: Backup task initiation, concurrent operations, plugin crash logs

- **Plugin Layer**
  - **Namespace / Pod pattern**: Included within Velero deployment
  - **Log locations**: Plugin specific logs
  - **Metrics / Traces to check**: Threading operations, crash diagnostics

- **IaaS (Infrastructure as a Service)**
  - **Namespace / Pod pattern**: Infrastructure-dependent
  - **Log locations**: Infrastructure operation logs
  - **Metrics / Traces to check**: Resource allocation, snapshot storage operations

### 2. Symptom Recognition

[Source: "The root cause was not propagated back to the Snapshot Service."]

#### Observed Symptoms
- **User-visible symptoms**: Snapshot requests not completing successfully
- **System signals or metrics**: Inconsistent logs indicating partial failures across services

#### Detection Clues
- **Keywords or anomalies**:
  - Log entries indicating plugin crash
  - Anomalies in Velero task concurrency logs
  - Errors or warnings in synchronization logs between Snapshot Service and Velero

### 3. Investigation Procedure

#### Step 1: Check Entry Service - Customer UI/Script
- **Commands**: Check script logs for initiation errors (e.g., check local script outputs).
- **Expected**: Snapshot request logs should proceed to Snapshot Service without errors.
- If anomaly found → proceed downstream to Snapshot Service.

#### Step 2: Check Middle Layer - Snapshot Service
- **Logs**: `/var/log/hana-snapshot-operator/yyyy-mm-dd.log` in `hc-snapshot` namespace.
- **Metrics**: Error rate in conversion tasks.
- **If delay/errors found**: Confirm if the Velero handoff is operational and pursue Velero logs for issues.
- Else → move to Velero Service.

#### Step 3: Check Downstream - Velero
- **Logs**: `/var/log/velero/yyyy-mm-dd.log` in `velero` namespace.
- **Metrics**: Check for increased error rates, concurrency warnings.
- **Investigation Focus**: Identify plugin crash logs, thread mismanagement, concurrent task logs.
- Else → move to Plugin/IaaS layers.

#### Step 4: Final Downstream Check - Plugin/IaaS
- **Verify state, connectivity, or queue**:
  - **Resource State**: Use Kubernetes resource checks (kubectl get pods/resources) to verify state.
  - **Connectivity issues**: Verify network connectivity or queue statuses related to storage operations.