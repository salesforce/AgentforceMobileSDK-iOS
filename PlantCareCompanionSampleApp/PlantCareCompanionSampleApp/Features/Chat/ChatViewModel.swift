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
import AgentforceSDK

@MainActor
@Observable
class ChatViewModel {
    
    // MARK: - Dependencies
    
    private let agentforceClient: PlantCareAgentforceClient
    
    // MARK: - State
    
    var chatView: AgentforceChatView?
    var isLoading = false
    var error: PlantCareError?
    
    // MARK: - Initialization
    
    init(agentforceClient: PlantCareAgentforceClient) {
        self.agentforceClient = agentforceClient
        setupChatView()
    }
    
    // MARK: - Setup
    
    private func setupChatView() {
        do {
            chatView = try agentforceClient.createChatView { [weak self] in
                self?.handleClose()
            }
        } catch let error as PlantCareError {
            self.error = error
        } catch {
            self.error = .networkError(error)
        }
    }
    
    // MARK: - Actions
    
    func sendMessage(_ message: String) {
        Task {
            do {
                try await agentforceClient.sendMessage(message)
                PlantCareAnalytics.shared.trackEvent("message_sent")
            } catch let error as PlantCareError {
                self.error = error
            } catch {
                self.error = .networkError(error)
            }
        }
    }
    
    private func handleClose() {
        Task {
            do {
                try await agentforceClient.closeConversation()
            } catch {
                print("Error closing conversation: \(error)")
            }
        }
    }
    
    func dismissError() {
        error = nil
    }
}

