// AgentforceManager.swift
//
// Owns the AgentforceClient, the active AgentConversation, and the
// AgentforceChatView. Must be retained at app root (`@StateObject`) so
// the conversation isn't dropped when leaf views unmount.
//
// This template covers all three modes — the skill should delete the
// branches that don't apply to the chosen flow.

import Foundation
import SwiftUI
import AgentforceSDK
import AgentforceService
import SalesforceLogging

@MainActor
final class AgentforceManager: ObservableObject {

    private var client: AgentforceClient?
    @Published private(set) var conversation: AgentConversation?
    @Published private(set) var chatView: AgentforceChatView?

    private let delegate = AppAgentforceDelegate()

    init() {
        configure()
    }

    // MARK: - Configuration

    private func configure() {
        let logger = AgentforceConsoleLogger()

        // ── EMPLOYEE AGENT ──────────────────────────────────────────────
        // Uncomment for `.employeeAgent` mode (OAuth or OrgJWT).
        //
        // let employeeConfig = EmployeeAgentConfiguration(
        //     user: User(
        //         userId: "{{USER_ID}}",
        //         org: Org(id: "{{ORG_ID}}"),
        //         username: "{{USERNAME}}",
        //         displayName: "{{DISPLAY_NAME}}"
        //     ),
        //     forceConfigEndpoint: "{{FORCE_CONFIG_ENDPOINT}}",
        //     authProvider: AppCredentialProvider()
        // )
        // .withLogger(logger)
        //
        // client = AgentforceClient(
        //     credentialProvider: AppCredentialProvider(),
        //     mode: .employeeAgent(employeeConfig)
        // )
        //
        // conversation = client?.startAgentforceConversation(
        //     forAgentId: "{{AGENT_ID}}",
        //     sessionId: nil
        // )

        // ── PUBLIC SERVICE AGENT ────────────────────────────────────────
        // Uncomment for `.serviceAgent` mode. No credential provider needed.
        //
        // let serviceConfig = ServiceAgentConfiguration(
        //     esDeveloperName: "{{ES_DEVELOPER_NAME}}",
        //     organizationId: "{{ORG_ID}}",
        //     serviceApiURL: "{{SERVICE_API_URL}}",
        //     serviceUISettings: ServiceUISettings(),
        //     forceConfigEndPoint: "{{FORCE_CONFIG_ENDPOINT}}"
        // )
        // .withLogger(logger)
        //
        // client = AgentforceClient(
        //     credentialProvider: serviceConfig.authProvider,
        //     mode: .serviceAgent(serviceConfig)
        // )
        //
        // conversation = client?.startAgentforceConversation(
        //     forESDeveloperName: serviceConfig.esDeveloperName
        // )

        chatView = makeChatView()
    }

    private func makeChatView() -> AgentforceChatView? {
        guard let client, let conversation else { return nil }
        return try? client.createAgentforceChatView(
            conversation: conversation,
            delegate: delegate,
            showTopBar: true,
            onContainerClose: { [weak self] in
                // Surface dismiss to the host. The host owns the
                // presentation flag (sheet/fullScreenCover/etc).
                self?.chatView = nil
            }
        )
    }

    // MARK: - Public API for SwiftUI hosts

    func sendMessage(_ text: String, attachment: AgentforceAttachment? = nil) async {
        await conversation?.sendUtterance(utterance: text, attachment: attachment)
    }

    func endConversation() async throws {
        try await conversation?.endConversation()
    }

    func closeConversation() async throws {
        try await conversation?.closeConversation()
        conversation = nil
        chatView = nil
    }

    // MARK: - iOS 26+ Launcher

    @available(iOS 26.0, *)
    func makeLauncher(
        launchChatView: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> AgentforceLauncher? {
        guard let client, let chatView else { return nil }
        return client.createAgentforceLauncher(
            chatView: chatView,
            launchChatView: launchChatView
        )
    }
}
