# AgentforceClient setup reference

## The three constructor shapes

### Employee agent (OAuth or OrgJWT)

```swift
let employeeConfig = EmployeeAgentConfiguration(
    user: User(userId: "...", org: Org(id: "..."), username: "...", displayName: "..."),
    forceConfigEndpoint: "https://mycompany.my.salesforce.com",
    authProvider: AppCredentialProvider()
)
.withLogger(AgentforceConsoleLogger())

let client = AgentforceClient(
    credentialProvider: AppCredentialProvider(),
    mode: .employeeAgent(employeeConfig)
)
```

### Public service agent

```swift
let serviceConfig = ServiceAgentConfiguration(
    esDeveloperName: "MyServiceAgent",
    organizationId: "00D...",
    serviceApiURL: "https://mycompany.my.salesforce-scrt.com",
    serviceUISettings: ServiceUISettings(),
    forceConfigEndPoint: "https://mycompany.my.salesforce.com"
)
.withLogger(AgentforceConsoleLogger())

let credentialProvider = AppCredentialProvider(
    guestURL: "https://mycompany.my.salesforce.com"
)

let client = AgentforceClient(
    credentialProvider: credentialProvider,
    mode: .serviceAgent(serviceConfig)
)
```

The `credentialProvider:` initializer argument is explicit for every mode. Keep the provider live so a verified or passthrough deployment can later replace guest credentials without rebuilding the client lifecycle.

> **`forceConfigEndPoint` is required on `ServiceAgentConfiguration`** (no default). Omitting it fails to compile with `missing argument for parameter 'forceConfigEndPoint'`. Pass the org's Salesforce domain (the same value used for the guest `url`, e.g. `https://mycompany.my.salesforce.com`) — this is distinct from `serviceApiURL`, which is the MIAW `-scrt` endpoint. Note the casing quirk in the SDK: `ServiceAgentConfiguration` spells it `forceConfigEndPoint` (capital `P`), whereas `EmployeeAgentConfiguration`/`AgentforceConfiguration` use `forceConfigEndpoint` (lowercase `p`). Verified against the SPM binary `AgentforceMobileSDK-262-1-3-spm` at tag `18.26.17`.

### Full config (escape hatch)

```swift
let config = AgentforceConfiguration(
    user: currentUser,
    forceConfigEndpoint: "https://mycompany.my.salesforce.com",
    agentforceFeatureFlagSettings: AgentforceFeatureFlagSettings(),
    salesforceNetwork: networkManager,
    salesforceNavigation: navigationHandler,
    salesforceLogger: AgentforceConsoleLogger()
)

let client = AgentforceClient(
    credentialProvider: AppCredentialProvider(),
    mode: .fullConfig(config)
)
```

## Retention

`AgentforceClient` must outlive every `AgentConversation` it creates. Idiomatic ownership:

```swift
@MainActor
final class AgentforceManager: ObservableObject {
    private var client: AgentforceClient?
    @Published private(set) var conversation: AgentConversation?
    @Published private(set) var chatView: AgentforceChatView?
    // ...
}
```

…and at app root:

```swift
@main
struct MyApp: App {
    @StateObject private var agentforceManager = AgentforceManager()
    // ...
}
```

`@StateObject` ensures the manager survives view rebuilds. Don't put `AgentforceManager()` in `@State` inside a leaf view — it'll be re-created and the conversation lost.

## Starting conversations

```swift
// Employee / full-config: agent ID
let conversation = client.startAgentforceConversation(
    forAgentId: "0Xx...",
    sessionId: nil  // or a previously-saved session ID to resume
)

// Service agent: ES developer name (NOT agent ID)
let conversation = client.startAgentforceConversation(
    forESDeveloperName: "MyServiceAgent"
)
```

## Conversation lifecycle

| Method | Behavior |
|---|---|
| `sendUtterance(utterance:attachment:)` async | Send a message. `attachment` is `AgentforceAttachment?` (image/PDF/etc). |
| `endConversation()` async throws | End but allow resume by sending a new utterance. |
| `closeConversation()` async throws | Close permanently. Cannot be resumed. |
| `downloadTranscript()` async throws | Returns `AgentforceTranscript` with `.url` to a PDF (Service Agents only). |

Subscribe to messages with the `messages` Combine publisher on `AgentConversation`.

## Creating the chat view

```swift
let chatView = try client.createAgentforceChatView(
    conversation: conversation,
    delegate: agentforceUIDelegate,
    showTopBar: true,
    onContainerClose: { /* dismiss the surface */ }
)
```

Throws if the client is misconfigured (e.g. wrong mode for the conversation type). Cache the returned `AgentforceChatView` on the manager — the SwiftUI host should re-use the same instance, not call `createAgentforceChatView` on every render.
