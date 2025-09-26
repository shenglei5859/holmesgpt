Please follow these principles:
1. Do not change code because upstream keeps changing, extend the function with runbooks/templates instead.
2. If code change is necessary, please open another branch.
3. Rebase instead of merge.
4. Using GPT5 series is strongly recommanded.

## Definition of Goals and Scopes

The goal: AI Automation for efficiency improvement.

A certain degree of tolerance for randomness and accuracy is accpetable.

As long as we can provide valuable recommendations, even if we can't deliver a precise end-to-end solution, it's still meaningful.

### Project homogenization:

 - The difference from other departments' Agents: Our architecture is much more complex (application-layer Agents cannot solve our problems), and we have our own troubleshooting procedures, which is able for us to extend HolmesGPT through Templates.
 - The difference from internal projects: Existing internal projects focus on specific platforms or platform categories. HolmesGPT can cover a larger scope (as shown in the diagram).

<img width="3114" alt="holmesgpt-architecture-diagram" src="https://github.com/user-attachments/assets/f659707e-1958-4add-9238-8565a5e3713a" />


Standard Agent Project Lifecycle:

1. Architecture design, project structure division
2. LLM interface alignment (Interaction: asynchronous bidirectional Streaming-Http or stdio, Multi-model: Python libraries, future AI Gateway)
3. MCP development (various Tools, call chain development, RBAC, etc.)
4. Prompt engineering (RAG, runbooks, templates)
5. Deployment method transformation (local code pulling and running -> Service transformation, supporting single-instance multi-user calls, frontend UI, etc.; introducing AI Gateway)
6. Continuously collect user feedback, update RAG (similar to reinforcement learning, but unrelated to training)

**HolmesGPT currently has 1, 2, and 3 relatively well-developed, 5 may be implemented in the future, and 6 is not the current goal. Therefore, we can focus on exploring AI's boundaries through prompt engineering.** 

**Objectively, for domain-specific problems, open-source projects are generally not as good as finely-tuned closed-source projects in most cases.**



Future directions:

1. A/B test model performance. For example, we found that GPT-5 is significantly more intelligent than the currently widely-used 4o, and has lower token pricing.
2. The longer the Tool call chain, the more likely it is to encounter limit issues. Even if dozens of Tool calls don't hit limits, for effectiveness we should minimize call frequency ------>Log deduplication, reduce input, while also reducing token usage to save costs.
3. AI effectiveness depends on the accuracy of observability platforms/distributed tracing/Service Pod Logs. Can we aggregate related errors at the observability platform level, allowing AI to give relatively precise conclusions through a few simple Tool calls? (We shouldn't write a Runbook for every problem, because it's impossible to enumerate them all)
4. Based on 3, is it possible to integrate current observability platform data? ----> Observability 2.0 (aggregation of Logs/Metrics/Traces)
