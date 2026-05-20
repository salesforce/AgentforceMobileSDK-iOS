// Sheet-style chat presentation. Open with a button; close by swiping down
// or tapping the SDK's built-in close button.

import SwiftUI
import AgentforceSDK

struct AgentforceChatHost: View {
    @EnvironmentObject var agentforce: AgentforceManager
    @State private var showChat = false

    var body: some View {
        Button {
            showChat = true
        } label: {
            Label("Ask the agent", systemImage: "bubble.left.and.bubble.right.fill")
        }
        .sheet(isPresented: $showChat) {
            if let chatView = agentforce.chatView {
                chatView
            } else {
                Text("Agent is not ready.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}
