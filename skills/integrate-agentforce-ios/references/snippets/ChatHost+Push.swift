// Push-into-NavigationStack presentation. Use when the chat is one step
// in a larger navigation flow.

import SwiftUI
import AgentforceSDK

struct AgentforceChatHost: View {
    @EnvironmentObject var agentforce: AgentforceManager

    var body: some View {
        NavigationLink {
            if let chatView = agentforce.chatView {
                chatView
                    .navigationTitle("Agent")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Agent is not ready.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        } label: {
            Label("Ask the agent", systemImage: "bubble.left.and.bubble.right.fill")
        }
    }
}
