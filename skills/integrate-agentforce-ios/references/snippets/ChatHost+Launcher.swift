// AgentforceLauncher (iOS 26+) presentation.
//
// The launcher lives in the tab bar's bottom accessory slot. On iOS < 26,
// the launcher is hidden — provide a fallback (sheet button) elsewhere in
// your UI for older OS targets.

import SwiftUI
import AgentforceSDK

struct AgentforceChatHost: View {
    @EnvironmentObject var agentforce: AgentforceManager
    @State private var launcher: AgentforceLauncher?
    @State private var showChat = false

    var body: some View {
        TabView {
            // TODO: Your tabs go here.
            Text("Home")
                .tabItem { Label("Home", systemImage: "house") }
        }
        .modifier(LauncherModifier(launcher: launcher))
        .sheet(isPresented: $showChat) {
            if let chatView = agentforce.chatView {
                chatView
            }
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
