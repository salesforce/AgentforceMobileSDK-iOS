// Push-into-NavigationStack presentation. Use when the chat is one step
// in a larger navigation flow.

import SwiftUI
import AgentforceSDK

struct AgentforceChatHost: View {
    var body: some View {
        NavigationLink {
            AgentforcePushDestination()
        } label: {
            Label("Ask the agent", systemImage: "bubble.left.and.bubble.right.fill")
        }
    }
}

private struct AgentforcePushDestination: View {
    @EnvironmentObject var agentforce: AgentforceManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let chatView = agentforce.chatView {
                chatView
                    .navigationTitle("Agent")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView("Starting Agentforce…")
            }
        }
        .onAppear {
            agentforce.prepareChatView { dismiss() }
        }
    }
}
