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
/// This class demonstrates the recommended integration pattern for AgentforceSDK:
/// 1. Initialize the SDK client with proper configuration
/// 2. Manage conversation lifecycle
/// 3. Handle UI view creation
@MainActor
class PlantCareAgentforceClient: ObservableObject {
    
    // MARK: - Properties
    
    private var agentforceClient: AgentforceClient?
    @Published private(set) var currentConversation: AgentConversation?
    @Published private(set) var currentChatView: AgentforceChatView?
    @Published private(set) var currentVoiceView: AgentforceVoiceView?
    
    @Published private(set) var isInitialized = false
    
    private let delegate: PlantCareDelegate
    private let settings: PlantCareSettings
    private var themeManager: CustomizableThemeManager?

    private var serviceAgentDeveloperName: String?
    
    // MARK: - Initialization
    
    init(settings: PlantCareSettings) {
        self.settings = settings
        self.delegate = PlantCareDelegate()
        self.delegate.analyticsHandler = PlantCareAnalytics.shared

        setupClient()

        settings.onNeedsReinitialize = { [weak self] in
            Task { @MainActor in
                self?.reinitialize()
            }
        }
    }
    
    // MARK: - Client Setup
    
    private func setupClient() {
        // MARK: 1 - Create Theme Manager
        let themeManager = CustomizableThemeManager(themeMode: settings.themeMode)
        self.themeManager = themeManager
        
        // MARK: 2 - Turn on voice feature flag
        // Enable voice mode
        let featureFlagSettings = AgentforceFeatureFlagSettings(enableVoice: true)
        
        // MARK: 2 - Create Agentforce Configuration
        
        // Service Agent (AgentAPI) Mode'
        let user = User(
            userId: "",
            org: Org(id: ""),
            username: "",
            displayName: "Plant Enthusiast"
        )
        
        // Create a configuration
        let fullConfiguration = AgentforceConfiguration(
            // Basic user information
            user: user,
            // Pass in a guest auth provider
            authProvider: PlantCareCredentialProvider(forceConfigEndpoint: settings.forceConfigEndpoint),
            // Pass in your mydomain
            forceConfigEndpoint: settings.forceConfigEndpoint,
            // Provide feature flags
            agentforceFeatureFlagSettings: featureFlagSettings,
            // Provide connection info
            agentforceConnectionInfo: AgentforceConnectionInfo(
                sfapURL: "https://api.salesforce.com",
                tenantId: ""
            ),
            salesforceNetwork: nil,
            salesforceNavigation: nil,
            // Provide custom color tokens
            themeManager: themeManager
        )
        
        // MARK: 4 - Create a client
        
        // Initialize Agentforce client with credentials, mode, view provider, and theme manager
        agentforceClient = AgentforceClient(
            mode: .fullConfig(fullConfiguration)
        )
        
        // MARK: 5 - Start Conversation
        currentConversation = agentforceClient?.startAgentforceConversation(forAgentId: settings.agentId)
        
        PlantCareAnalytics.shared.trackEvent("conversation_started")
    }
    
    func reinitialize() {
        currentChatView = nil
        currentVoiceView = nil
        currentConversation = nil
        agentforceClient = nil
        setupClient()
    }
    
    // MARK: 6 Create Chat View
    func getChatView(onClose: @escaping () -> Void) -> AgentforceChatView? {
        if let chatView = currentChatView {
            return chatView
        }
        return try? createChatView(onClose: onClose)
    }

    // MARK: 7 Create Voice View
    func getVoiceView(onContainerClose: @escaping () -> Void) -> AgentforceVoiceView? {
        if let voiceView = currentVoiceView {
            return voiceView
        }
        guard let client = agentforceClient, let conversation = currentConversation else { return nil }
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
            throw PlantCareError.failedToStartConversation
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
        PlantCareAnalytics.shared.trackEvent("conversation_closed")
    }
    
    // MARK: - View Creation
    
    /// Creates an AgentforceChatView for the current conversation
    func createChatView(onClose: @escaping () -> Void) throws -> AgentforceChatView {
        guard let client = agentforceClient else {
            throw PlantCareError.sdkNotInitialized
        }
        
        guard let conversation = currentConversation else {
            throw PlantCareError.failedToStartConversation
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
    
}

// MARK: - Instrumentation Handler

class PlantCareInstrumentationHandler: AgentforceInstrumentationHandling {
    func handleInstrumentationEvent(event: AgentforceInstrumentationEvent) {
        // Handle instrumentation events
        print(event)
    }
}
