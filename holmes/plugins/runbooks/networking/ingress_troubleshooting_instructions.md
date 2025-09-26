# Ingress Troubleshooting Guidelines (Kubernetes)

## Goal
Your primary goal when using these tools is to diagnose ingress resolution issues within a Kubernetes cluster, focusing on identifying common problems like ip whitelist and issues like being forbidden to access.

*   Use the tools to gather information about the ingress pods, services, and configuration.
*   Clearly present the key findings from the tool outputs in your analysis.
*   Instead of provide next steps to the user, you need to follow the troubleshoot guide to execute the steps.
*   When getting pod logs, always try to get the log filter by log_filter toolset to filter out unnecessary logs by tool kubectl_logs_grep_no_match

## Workflow for Ingress Diagnosis

1.  **Learn ingress knowledge:**
    *   Fetch web content from https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip collect context about source ip. Take the content into account and troubleshoot the issue again.

1.  **Check servie configuration:**
    *   Check kubernetes service whose type is 'LoadBalancer'.
    *   Findout any configuration that may cause ingress issues.

2.  **Check ingress logs:**
    *   Check the logs of ingress pod

3.  **Check ip related things:**
    *   Check the source ip and compare with ip white list or black list
