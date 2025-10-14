#!/bin/bash

generate_suffix() {
  printf '%05x' $((RANDOM * RANDOM % 1048576))
}

generate_time() {
  # 2025-09-22 的时间范围
  hours=$((RANDOM % 24))
  minutes=$((RANDOM % 60))
  seconds=$((RANDOM % 60))
  printf "2025-09-22T%02d:%02d:%02dZ" $hours $minutes $seconds
}

BASE_UUID="8a875b01-71f8-4b69-bf93-371b40ce7946"
COUNT=${1:-10}
NAMESPACE=${2:-default}

for i in $(seq 1 $COUNT); do
  SUFFIX=$(generate_suffix)
  TIME=$(generate_time)
  NAME="${BASE_UUID}-${SUFFIX}"
  
  # 创建资源
  kubectl apply -f - <<EOF
apiVersion: hana.sap.com/v1beta1
kind: HanaSnapshot
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
  labels:
    operationType: create
    service_instance_id: ${BASE_UUID}
spec:
  instanceID: "hana-${BASE_UUID}"
  hanaStorage: 107374182400
  productVersion:
    name: "HANA 2.0"
    id: "hana-2.0-sp07"
EOF

  # 更新 status
  kubectl patch hanasnapshot ${NAME} -n ${NAMESPACE} --subresource=status --type=merge -p "{
    \"status\": {
      \"lastOperation\": {
        \"state\": \"CreationFailed\",
        \"description\": \"failed to create volume snapshot\"
      },
      \"snapshotTimestamp\": \"${TIME}\"
    }
  }"

  echo "Created: ${NAME}"
done