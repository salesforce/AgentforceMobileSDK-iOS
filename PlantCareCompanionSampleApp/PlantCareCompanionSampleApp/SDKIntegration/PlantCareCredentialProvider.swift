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
import AgentforceService

// NOTE: This is a mock implementation for demonstration purposes.
// In a production app, you would integrate with a real authentication system.

/// Provides authentication credentials for Agentforce SDK
class PlantCareCredentialProvider: AgentforceAuthCredentialProviding {
    
    private var accessToken: String
    private var orgId: String
    private var userId: String
    
    init() {
        // In a real app, load saved credentials from Keychain or Salesforce SDK
        self.accessToken = "mock_access_token_\(UUID().uuidString)"
        self.orgId = "00D000000000000EAA"  // Mock org ID
        self.userId = "005000000000000AAA"  // Mock user ID
    }
    
    // MARK: - AgentforceAuthCredentialProviding
    
    func getAuthCredentials() -> AgentforceAuthCredentials {
        return .OAuth(
            authToken: accessToken,
            orgId: orgId,
            userId: userId
        )
    }
    
    // MARK: - Helper Methods
    
    func getInstanceURL() -> String? {
        // In a real app, this would come from Salesforce SDK or user config
        return "https://plantcare-demo.my.salesforce.com"
    }
    
    func setCredentials(accessToken: String, orgId: String, userId: String) {
        self.accessToken = accessToken
        self.orgId = orgId
        self.userId = userId
    }
    
    func clearCredentials() {
        self.accessToken = ""
        self.orgId = ""
        self.userId = ""
    }
}

