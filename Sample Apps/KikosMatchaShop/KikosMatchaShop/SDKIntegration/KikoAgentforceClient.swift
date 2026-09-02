/*
 Copyright (c) 2020-present, salesforce.com, inc. All rights reserved.

 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import Foundation
import SwiftUI
import Combine
import AgentforceSDK
import AgentforceService
import SalesforceNetwork
import SalesforceUser

/// Wrapper around AgentforceSDK client
///
/// This class demonstrates the recommended integration pattern for AgentforceSDK with
/// guest authentication:
/// 1. Initialize the SDK client with a full (guest) configuration
/// 2. Manage conversation lifecycle
/// 3. Handle chat and voice view creation
@MainActor
class KikoAgentforceClient: ObservableObject {

    // MARK: - Properties

    private var agentforceClient: AgentforceClient?
    @Published private(set) var currentConversation: AgentConversation?
    @Published private(set) var currentChatView: AgentforceChatView?
    @Published private(set) var currentVoiceView: AgentforceVoiceView?

    @Published private(set) var isInitialized = false

    /// Exposed so the UI can hook `onVoiceInitiated` (the in-chat voice button).
    let delegate: KikoDelegate
    private let settings: KikoSettings

    // MARK: - Initialization

    init(settings: KikoSettings) {
        self.settings = settings
        self.delegate = KikoDelegate()
        self.delegate.analyticsHandler = KikoAnalytics.shared

        setupClient()
    }

    // MARK: - Client Setup

    private func setupClient() {
        // Only initialize once guest auth is configured (My Domain URL + Agent ID).
        guard settings.isConfigured else {
            agentforceClient = nil
            currentConversation = nil
            return
        }

        // MARK: 1 - Create Theme Manager (drives the chat UI's light/dark appearance)
        let themeManager = settings.createThemeManager()

        // MARK: 2 - Create Custom View Provider
        let viewProvider = CustomMatchaViewProvider()

        // MARK: 3 - Describe the guest user
        // Guest auth doesn't identify a real user, so these fields are empty; only the
        // display name is surfaced in the UI.
        let user = User(
            userId: "",
            org: Org(id: ""),
            username: "",
            displayName: "Matcha Enthusiast"
        )

        // MARK: 4 - Build the full (guest) configuration, then layer brand colors on top
        let configuration = AgentforceConfiguration(
            user: user,
            authProvider: KikoCredentialProvider(forceConfigEndpoint: settings.forceConfigEndpoint),
            forceConfigEndpoint: settings.forceConfigEndpoint,
            agentforceFeatureFlagSettings: settings.createFeatureFlagSettings(),
            agentforceConnectionInfo: AgentforceConnectionInfo(
                sfapURL: settings.effectiveSFAPURL,
                tenantId: ""
            ),
            salesforceNetwork: nil,
            salesforceNavigation: nil,
            themeManager: themeManager
        ).setTheming(BrandTheme.theming)

        // MARK: 5 - Create the Agentforce client
        agentforceClient = AgentforceClient(
            mode: .fullConfig(configuration),
            viewProvider: viewProvider
        )

        // MARK: 6 - Start the conversation against the configured agent
        currentConversation = agentforceClient?.startAgentforceConversation(
            forAgentId: settings.agentId
        )

        KikoAnalytics.shared.trackEvent("conversation_started")
    }

    /// Tears down and rebuilds the client so credential/theme changes from Settings
    /// take effect without an app restart.
    func reinitialize() {
        currentChatView = nil
        currentVoiceView = nil
        currentConversation = nil
        agentforceClient = nil
        setupClient()
    }

    func getChatView(onClose: @escaping () -> Void) -> AgentforceChatView? {
        if let chatView = currentChatView {
            return chatView
        }
        return try? createChatView(onClose: onClose)
    }

    /// Returns the voice view for the current conversation, creating it on first use.
    func getVoiceView(onContainerClose: @escaping () -> Void) -> AgentforceVoiceView? {
        if let voiceView = currentVoiceView {
            return voiceView
        }
        guard let client = agentforceClient, let conversation = currentConversation else {
            return nil
        }
        let voiceView = try? client.createAgentforceVoiceView(
            conversation: conversation,
            onContainerClose: onContainerClose
        )
        currentVoiceView = voiceView
        return voiceView
    }
    
    /// Sends a message in the current conversation
    func sendMessage(_ message: String, attachment: Data? = nil) async throws {
        guard let conversation = currentConversation else {
            throw KikoError.failedToStartConversation
        }
        
        let agentforceAttachment: AgentforceAttachment?
        if let data = attachment {
            agentforceAttachment = AgentforceAttachment(
                name: "attachment.jpg",
                attachmentType: .Image(data),
                mimeType: "image/jpeg"
            )
        } else {
            agentforceAttachment = nil
        }
        
        await conversation.sendUtterance(utterance: message, attachment: agentforceAttachment)
    }
    
    /// Closes the current conversation
    func closeConversation() async throws {
        guard let conversation = currentConversation else { return }
        
        try await conversation.closeConversation()
        currentConversation = nil
        KikoAnalytics.shared.trackEvent("conversation_closed")
    }
    
    // MARK: - View Creation
    
    /// Creates an AgentforceChatView for the current conversation
    func createChatView(onClose: @escaping () -> Void) throws -> AgentforceChatView {
        guard let client = agentforceClient else {
            throw KikoError.sdkNotInitialized
        }
        
        guard let conversation = currentConversation else {
            throw KikoError.failedToStartConversation
        }
        
        let chatView = try client.createAgentforceChatView(
            conversation: conversation,
            delegate: delegate,
            showTopBar: true,
            onContainerClose: onClose
        )
        currentChatView = chatView
        return chatView
    }
    
    /// Creates an AgentforceLauncher, initializing conversation and chat view if needed
    /// - Parameters:
    ///   - launchChatView: Closure called when the launcher is tapped to present the chat view
    ///   - onClose: Closure called when the close button is tapped in the chat view
    /// - Returns: An AgentforceLauncher view, or nil if prerequisites are not met
    func createLauncher(launchChatView: @escaping () -> Void, onClose: @escaping () -> Void) -> AgentforceLauncher? {
        guard let chatview = getChatView(onClose: onClose) else { return nil }
        
        return agentforceClient?.createAgentforceLauncher(
            chatView: chatview,
            launchChatView: launchChatView
        )
    }
}
