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
    
    @Published private(set) var isInitialized = false
    
    private let credentialProvider: PlantCareCredentialProvider
    private let delegate: PlantCareDelegate
    private let settings: PlantCareSettings
    
    private var serviceAgentDeveloperName: String?
    
    // MARK: - Initialization
    
    init(credentialProvider: PlantCareCredentialProvider, settings: PlantCareSettings) {
        self.credentialProvider = credentialProvider
        self.settings = settings
        self.delegate = PlantCareDelegate()
        self.delegate.analyticsHandler = PlantCareAnalytics.shared
        
        setupClient()
    }
    
    // MARK: - Client Setup
    
    private func setupClient() {
        // MARK: 1 - Create Theme Manager
        let themeManager = settings.createThemeManager()
        
        // MARK: 2 - Create Custom View Provider
        let viewProvider = CustomPlantViewProvider()
        
        // MARK: 3 - Create Agentforce Client
        // Only initialize if Service is configured
        guard let serviceConfig = settings.createServiceDeploymentConfig() else {
            // Service not configured - client won't be initialized
            agentforceClient = nil
            serviceAgentDeveloperName = nil
            return
        }
        
        // Service Agent Mode
        let mode: AgentforceMode = .serviceAgent(serviceConfig)
        serviceAgentDeveloperName = serviceConfig.esDeveloperName
        
        // Initialize Agentforce client with credentials, mode, view provider, and theme manager
        agentforceClient = AgentforceClient(
            credentialProvider: credentialProvider,
            mode: mode,
            viewProvider: viewProvider,
            themeManager: themeManager
        )
        
        // MARK: 4 - Start Conversation
        if let developerName = serviceAgentDeveloperName {
            // Service Agent mode: use forESDeveloperName
            currentConversation = agentforceClient?.startAgentforceConversation(
                forESDeveloperName: developerName
            )
        }
        
        PlantCareAnalytics.shared.trackEvent("conversation_started")
    }
    
    func getChatView(onClose: @escaping () -> Void) -> AgentforceChatView? {
        if let chatView = currentChatView {
            return chatView
        }
        return try? createChatView(onClose: onClose)
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

// MARK: - Instrumentation Handler

class PlantCareInstrumentationHandler: AgentforceInstrumentationHandling {
    func handleInstrumentationEvent(event: AgentforceInstrumentationEvent) {
        // Handle instrumentation events
        print(event)
    }
}
