# Auth flow reference

Pick the auth flow based on the use case. **Don't** lead with the credential type — most consumers won't know which one applies.

## The two `AgentforceMode` cases that drive most integrations

```swift
public enum AgentforceMode {
    case fullConfig(AgentforceConfiguration)
    case serviceAgent(ServiceAgentConfiguration)
    case employeeAgent(EmployeeAgentConfiguration)
}
```

- `.employeeAgent` — internal/employee tools, signed-in users. Requires a real `AgentforceAuthCredentialProviding`.
- `.serviceAgent` — public, customer-facing service agent (MIAW deployment). The SDK supplies its own `ServiceAgentAuthProvider` returning `.Guest(url: "")` internally — the consumer does **not** scaffold a credential provider.
- `.fullConfig` — escape hatch when you need to override the network layer, navigation handler, data provider, or other low-level pieces. Most consumers don't need this.

## The three `AgentforceAuthCredentials` cases

```swift
public enum AgentforceAuthCredentials {
    case OAuth(authToken: String, orgId: String, userId: String)
    case OrgJWT(orgJWT: String)
    case Guest(url: String)
}
```

`getAuthCredentials()` is called on every authenticated request, so return live values — don't cache a stale token. The SDK does not refresh tokens for you.

## Decision tree

```
Is the agent customer-facing (anyone can chat without signing in)?
├── Yes → AgentforceMode.serviceAgent + MIAW deployment
│         No credential provider needed.
│         Prerequisites: esDeveloperName, organizationId, serviceApiURL.
│         Setup: https://help.salesforce.com/s/articleView?id=service.miaw_deployment_mobile.htm&type=5
│
└── No (employees / signed-in users)
     │
     └── How is the user authenticated?
         │
         ├── Salesforce Mobile SDK (UserAccountManager)
         │   → AgentforceMode.employeeAgent
         │   → AgentforceAuthCredentials.OAuth(authToken, orgId, userId)
         │
         ├── Backend that issues a Salesforce-signed JWT
         │   → AgentforceMode.employeeAgent
         │   → AgentforceAuthCredentials.OrgJWT(orgJWT)
         │
         └── Other / public Agent API behind Experience Cloud
             → AgentforceMode.fullConfig (or .serviceAgent if applicable)
             → AgentforceAuthCredentials.Guest(url:)
             → Only suggest this when the user explicitly describes
               "public Agent API + Experience Cloud site + no JWT".
```

## When `.Guest(url:)` is correct

Only when **all** of these hold:

- The agent is publicly accessible.
- The consumer is going through the **Agent API** (not MIAW / service agent).
- The org exposes the agent via an **Experience Cloud site**.
- The consumer cannot or does not want to issue a JWT.

If any of these are unclear, default to `.serviceAgent` (Branch B in `SKILL.md`) — that's the path Salesforce expects for public agents on mobile.

## When `.OrgJWT` is correct

Only when **all** of these hold:

- Employee/internal users (signed-in).
- The consumer has a backend (or another mechanism) that mints a Salesforce-signed JWT for the user.
- They do **not** want to manage OAuth tokens directly.

JWT lifetime is the consumer's responsibility. `getAuthCredentials()` should fetch the *current* JWT each time — don't cache a fresh-at-init value, it'll expire.

## Prerequisites checklist

Before scaffolding, confirm the user has:

| Branch | Prerequisites |
|---|---|
| Service Agent | MIAW mobile deployment configured; `esDeveloperName`, `organizationId`, `serviceApiURL`, `forceConfigEndPoint` |
| Employee + OAuth | Salesforce Mobile SDK already integrated **or** a token source class to wrap; `forceConfigEndpoint`; `User` info |
| Employee + OrgJWT | A way to fetch a current JWT; `forceConfigEndpoint`; `User` info |
| Guest | Agent API endpoint URL; `forceConfigEndpoint`; `agentId` |
