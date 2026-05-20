// Full-screen cover presentation. Use when the chat is the primary task
// and shouldn't be dismissed by an accidental swipe.

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
            } else {
                Text("Agent is not ready.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}
