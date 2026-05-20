---
name: integrate-agentforce-ios
description: Integrate the Agentforce Mobile SDK into an existing iOS app. Walks the consumer through use-case discovery, picks the right auth flow (employee OAuth/JWT vs public service agent vs guest), adds the SPM or CocoaPods dependency, and scaffolds Swift files for the credential provider, AgentforceClient manager, OSLog-backed logger, UI delegate, and a SwiftUI chat host. Use when a developer asks to "add Agentforce", "integrate the Agentforce SDK", "set up Agentforce chat", or wire an iOS app up to a Salesforce agent.
---

# integrate-agentforce-ios

This skill walks a consumer through wiring the **Agentforce Mobile SDK** into their iOS app. It is **interactive** — ask the user the questions in each phase before generating code. Don't assume; the wrong auth flow is the most common integration mistake.

## Operating rules

- **Run inside the consumer's project, not inside the SDK repo.** If the working directory contains `Sources/AgentforceSDKTarget/` or `Package.swift` declares the product `AgentforceSDK` as a `binaryTarget`, refuse and tell the user to `cd` into their app first.
- **Discover before deciding.** Always run Phase 1 (use-case discovery) before recommending an auth flow. Don't ask "which auth flow do you want?" — most consumers don't know.
- **Don't suggest `.Guest(url:)` or `.OrgJWT` by default.** They're only correct in specific situations. Recommend the path that matches the user's described use case.
- **Retain the client for the conversation's lifetime.** `AgentforceClient` must live as long as the conversation; deallocating it loses the session. Always scaffold the client inside an `@MainActor` `ObservableObject` owned by `@StateObject` at the app root.
- **Use `AskUserQuestion` for branching choices.** Don't free-text prompts — give 2–4 explicit options.
- **Substitute placeholders, don't leave `{{TOKENS}}` in the final files.** Collect values up front; if the user can't provide a value, leave a clearly-marked `// TODO:` comment instead.

## Phase 0 — Detect the target project

Look in the current working directory for:

- `Package.swift` (SPM-only project), **or**
- `Podfile` (CocoaPods project), **or**
- `*.xcodeproj` / `*.xcworkspace` (Xcode project; could use either)

If none is present, ask the user where the iOS project root is and `cd` there. If `Sources/AgentforceSDKTarget/` exists at the working directory, refuse — that's this SDK's own repo.

See `references/dep-manager-detection.md` for the full decision tree.

## Phase 1 — Discover the use case (this drives auth)

Ask **first** what they're building, then map to an auth flow:

```
AskUserQuestion: "What kind of agent are you integrating?"
  - Employee agent (signed-in users, internal tools)         → AgentforceMode.employeeAgent
  - Public service agent (customer-facing, no sign-in)       → AgentforceMode.serviceAgent
  - Other / not sure                                          → see references/auth-flows.md
```

### Branch A — Employee agent

Ask the follow-up:

```
AskUserQuestion: "How are you obtaining auth credentials?"
  - Salesforce Mobile SDK   → AgentforceAuthCredentials.OAuth(authToken, orgId, userId)
  - Org JWT                 → AgentforceAuthCredentials.OrgJWT(orgJWT)
```

- **Salesforce Mobile SDK**: scaffold `AppCredentialProvider` from `references/snippets/AppCredentialProvider+OAuth.swift`. The provider's `getAuthCredentials()` reads from `UserAccountManager.shared.currentUserAccount` — or wraps the consumer's existing token-source class if they already have one.
- **Org JWT**: scaffold from `references/snippets/AppCredentialProvider+OrgJWT.swift`. Ask for the source of the JWT (a closure, a keychain key, or an environment value) and wire `getAuthCredentials()` to call into it on every invocation. Don't cache.

### Branch B — Public service agent

This is the **simplest** path:

- Use `AgentforceMode.serviceAgent(ServiceAgentConfiguration)`.
- **Do not scaffold a credential provider** — the SDK's internal `ServiceAgentAuthProvider` is used automatically.
- Tell the user they'll need a **Messaging-for-In-App-Web (MIAW) mobile deployment** in their Salesforce org first, and link the docs:
  - https://help.salesforce.com/s/articleView?id=service.miaw_deployment_mobile.htm&type=5
- If they don't have one yet, pause here. The skill can't proceed without `esDeveloperName`, `organizationId`, and `serviceApiURL` from the deployment.

### Branch C — Other / not sure

Walk them through `references/auth-flows.md`. The two extra options to surface here:

- `.Guest(url:)` — only for Service Agent on the public Agent API behind an Experience Cloud site, when URL-only guest credentials are required. Most "public agent" cases should use Branch B instead.
- `.OrgJWT` — already covered in Branch A.

## Phase 2 — Pick the chat presentation point

```
AskUserQuestion: "Where should the chat UI live?"
  - Sheet (recommended)                                    → ChatHost+Sheet.swift
  - Full-screen cover                                      → ChatHost+FullScreen.swift
  - Push in NavigationStack                                → ChatHost+Push.swift
  - AgentforceLauncher (iOS 26+ tab bar accessory)         → ChatHost+Launcher.swift
```

Each option corresponds to one snippet in `references/snippets/`. The launcher path requires `iOS 26+` — gate with `#available(iOS 26.0, *)` and provide a sheet fallback for earlier OS targets.

See `references/chat-presentation.md` for the patterns and the `tabViewBottomAccessory` setup.

## Phase 3 — Collect config values

Based on the chosen branch:

| Branch | Required values |
|---|---|
| Employee + Mobile SDK | `forceConfigEndpoint` (instance URL, e.g. `https://mycompany.my.salesforce.com`); `User` fields (`userId`, `org.id`, `username`, `displayName`); `agentId` |
| Employee + Org JWT | Same as above, plus the JWT source (closure / keychain key / env) |
| Public Service Agent | `esDeveloperName`, `organizationId`, `serviceApiURL`, `forceConfigEndPoint` |
| Guest (via "Other") | `url`, `forceConfigEndpoint`, `agentId` |

Ask one question per missing value. If the user gives "I don't know" for a Service Agent value, point them back at the MIAW deployment link and stop.

## Phase 4 — Add the dependency

Pick the path based on Phase 0 detection. Prefer SPM if both are present.

### SPM

For `Package.swift`-based projects, add to `dependencies`:

```swift
.package(url: "https://github.com/salesforce/AgentforceMobileSDK-iOS.git", from: "15.5.1")
```

…and add `AgentforceSDK` (product name) to the relevant target's dependencies.

For `.xcodeproj`-only projects, walk the user through **File → Add Package Dependencies** in Xcode with the same URL. Don't try to edit `.xcodeproj` files by hand.

### CocoaPods

Edit `Podfile`. Mirror the structure from this SDK's sample app (`PlantCareCompanionSampleApp/Podfile`):

```ruby
target_deployment_version = '18.0'

target 'YourApp' do
  source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
  source 'https://github.com/livekit/podspecs.git'
  source 'https://cdn.cocoapods.org/'
  use_frameworks!

  pod 'AgentforceSDK'
  pod 'Messaging-InApp-Core'
  pod 'LiveKitClient'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

Then `pod install` (or `pod install --repo-update` if specs aren't found).

See `references/dep-manager-detection.md` for the full Podfile, including static-linking variants.

## Phase 5 — Scaffold Swift files

Create the directory `Agentforce/` at the app target root and write the following, substituting placeholders with values from Phase 3:

| File | When | Source snippet |
|---|---|---|
| `AppCredentialProvider.swift` | Employee branches only | `snippets/AppCredentialProvider+OAuth.swift` or `+OrgJWT.swift` |
| `AgentforceConsoleLogger.swift` | Always | `snippets/AgentforceConsoleLogger.swift` |
| `AgentforceManager.swift` | Always | `snippets/AgentforceManager.swift` |
| `AgentforceUIDelegate+Default.swift` | Always | `snippets/AgentforceUIDelegate+Default.swift` |
| `AgentforceChatHost.swift` | Always | one of `snippets/ChatHost+*.swift` based on Phase 2 |

`AgentforceManager.swift` is parameterized by mode — pass the right `AgentforceMode` (`.employeeAgent`, `.serviceAgent`, or `.fullConfig`) and the right conversation-starter call (`startAgentforceConversation(forAgentId:)` for employee/full-config, `forESDeveloperName:` for service agents).

The logger is OSLog-backed (`SalesforceLogging.Logger` conformance, one `os.Logger` per `LogLevel` under subsystem `com.salesforce.agentforce`). It's wired via `.withLogger(...)` on `EmployeeAgentConfiguration` / `ServiceAgentConfiguration`, or via `salesforceLogger:` on `AgentforceConfiguration`. See `references/logger-setup.md`.

## Phase 6 — Wire into the App entry point

Patch the consumer's `@main` `App` struct:

```swift
@main
struct MyApp: App {
    @StateObject private var agentforceManager = AgentforceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(agentforceManager)
        }
    }
}
```

If the user already has a DI container or composition root, surface that — don't force a `@StateObject` if their architecture has another lifetime owner. The hard requirement is only that the manager outlives every conversation it creates.

## Phase 7 — Verify

Tell the user:

1. **Build**: `xcodebuild -workspace YourApp.xcworkspace -scheme YourApp -sdk iphonesimulator build` (or build in Xcode). Expect a clean build with no manual edits beyond placeholders.
2. **Retention check**: confirm `AgentforceManager` is owned at app-root (via `@StateObject`). If it's `@State` inside a leaf view, the conversation will drop when the view is unmounted.
3. **Run on simulator**, navigate to the chat surface, send a test utterance, watch for streamed response.
4. **Logs**: open Console.app, filter on subsystem `com.salesforce.agentforce` to see SDK loglines.
5. **Service Agent only**: if `userVerificationRequired = true`, remind them to wire a `UserVerificationDelegate`.

If the build fails, common causes:

- Missing `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` on Pods (CocoaPods only).
- Wrong source order in `Podfile` (Salesforce specs must be first).
- Static linking without the `cocoapods-user-defined-build-types` plugin.
- `AgentforceClient` instantiated on a non-main thread.

## References

- `references/auth-flows.md` — full credential-flow decision tree, including `.Guest` and `.OrgJWT` edge cases.
- `references/client-setup.md` — `AgentforceClient` init, mode selection, retention, conversation lifecycle.
- `references/logger-setup.md` — OSLog `SalesforceLogging.Logger` conformance.
- `references/chat-presentation.md` — sheet / fullScreenCover / push / launcher patterns.
- `references/dep-manager-detection.md` — SPM vs CocoaPods detection and full Podfile.
- `references/snippets/*.swift` — file templates with `{{PLACEHOLDERS}}` to substitute.
