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
import AgentforceService

/// Settings model for Plant Care Companion app
/// Manages theme configuration and Service deployment settings
@Observable
class PlantCareSettings {
    // MARK: - Service Agent API values
    
    // Replace this with your My Domain URL (e.g., "https://mycompany.my.salesforce.com")
    #error("Set your Salesforce My Domain URL below, then remove this line.")
    var forceConfigEndpoint = ""

    // Replace this with your agent ID: https://github.com/salesforce/AgentforceMobileSDK-iOS?tab=readme-ov-file#before-you-begin
    #error("Set your agent ID below, then remove this line.")
    var agentId = ""
    
    // MARK: - Initialization
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Theme Configuration
    
    var onNeedsReinitialize: (() -> Void)?

    var themeMode: AgentforceThemeMode = .system {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: "PlantCareThemeMode")
            onNeedsReinitialize?()
        }
    }
    
    // MARK: - UserDefaults Integration
    
    private func loadFromUserDefaults() {
        // Load theme configuration
        let themeModeString = UserDefaults.standard.string(forKey: "PlantCareThemeMode") ?? "system"
        themeMode = AgentforceThemeMode(rawValue: themeModeString) ?? .system
      
    }
    
    // MARK: - Helper Methods
    
    /// Reset all settings to their default values
    func resetToDefaults() {
        themeMode = .system
    }
}

