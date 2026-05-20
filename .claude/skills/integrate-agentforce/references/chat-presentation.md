# Chat presentation reference

`AgentforceChatView` is a SwiftUI `View`. Drop it into the app wherever a conversation should appear. The four common patterns:

## Sheet (recommended default)

A modal that slides up from the bottom. Best for "open the assistant" CTAs.

```swift
struct ContentView: View {
    @EnvironmentObject var agentforce: AgentforceManager
    @State private var showChat = false

    var body: some View {
        Button("Open Chat") { showChat = true }
            .sheet(isPresented: $showChat) {
                if let chatView = agentforce.chatView {
                    chatView
                }
            }
    }
}
```

## Full-screen cover

Same trigger pattern but the chat takes the full screen. Use when the chat is the primary task.

```swift
.fullScreenCover(isPresented: $showChat) {
    if let chatView = agentforce.chatView {
        NavigationStack {
            chatView
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { showChat = false }
                    }
                }
        }
    }
}
```

## NavigationStack push

Push the chat onto an existing navigation stack. Use when the chat is one step in a larger task flow.

```swift
NavigationStack {
    List {
        NavigationLink("Ask the agent") {
            if let chatView = agentforce.chatView {
                chatView
            }
        }
    }
}
```

## AgentforceLauncher (iOS 26+)

A floating action button that lives in the tab bar's bottom accessory slot. Available only on iOS 26+; provide a sheet/button fallback for earlier OS targets.

```swift
struct ContentView: View {
    @EnvironmentObject var agentforce: AgentforceManager
    @State private var launcher: AgentforceLauncher?
    @State private var showChat = false

    var body: some View {
        TabView {
            // ...tabs...
        }
        .modifier(LauncherModifier(launcher: launcher))
        .sheet(isPresented: $showChat) {
            agentforce.chatView
        }
        .onAppear {
            if #available(iOS 26.0, *) {
                launcher = agentforce.makeLauncher(
                    launchChatView: { showChat = true },
                    onClose: { showChat = false }
                )
            }
        }
    }
}

private struct LauncherModifier: ViewModifier {
    let launcher: AgentforceLauncher?
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory { launcher }
        } else {
            content
        }
    }
}
```

`AgentforceManager.makeLauncher(...)` wraps `client.createAgentforceLauncher(chatView:launchChatView:)`.

## Cache the chat view

`createAgentforceChatView(...)` is **not** idempotent — call it once per conversation and cache the result on the manager. Calling it on every SwiftUI render will spawn duplicate views and confuse the SDK's internal state.
