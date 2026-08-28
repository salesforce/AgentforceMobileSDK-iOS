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

/// Settings model for Kiko's Matcha Shop app
/// Manages theme configuration and Service deployment settings
@Observable
class KikoSettings {
    
    // MARK: - Theme Configuration
    
    var themeMode: AgentforceThemeMode = .system {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: "KikoThemeMode")
        }
    }
    
    // MARK: - Service Configuration
    
    var serviceAPI: String = "" {
        didSet {
            UserDefaults.standard.set(serviceAPI, forKey: "KikoServiceAPI")
        }
    }
    
    var organizationId: String = "" {
        didSet {
            UserDefaults.standard.set(organizationId, forKey: "KikoOrganizationId")
        }
    }
    
    var developerName: String = "" {
        didSet {
            UserDefaults.standard.set(developerName, forKey: "KikoDeveloperName")
        }
    }

    /// Org My Domain URL used to resolve force config (required for voice; chat works without it)
    var forceConfigEndpoint: String = "" {
        didSet {
            UserDefaults.standard.set(forceConfigEndpoint, forKey: "KikoForceConfigEndpoint")
        }
    }

    // MARK: - Feature Flags
    
    var enableMultiModalInput: Bool = true {
        didSet {
            UserDefaults.standard.set(enableMultiModalInput, forKey: "KikoFeatureFlag_enableMultiModalInput")
        }
    }
    
    var enablePDFFileUpload: Bool = true {
        didSet {
            UserDefaults.standard.set(enablePDFFileUpload, forKey: "KikoFeatureFlag_enablePDFFileUpload")
        }
    }
    
    var multiAgent: Bool = true {
        didSet {
            UserDefaults.standard.set(multiAgent, forKey: "KikoFeatureFlag_multiAgent")
        }
    }
    
    var shouldBlockMicrophone: Bool = false {
        didSet {
            UserDefaults.standard.set(shouldBlockMicrophone, forKey: "KikoFeatureFlag_shouldBlockMicrophone")
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - UserDefaults Integration
    
    private func loadFromUserDefaults() {
        // Load theme configuration
        let themeModeString = UserDefaults.standard.string(forKey: "KikoThemeMode") ?? "system"
        themeMode = AgentforceThemeMode(rawValue: themeModeString) ?? .system
        
        // Load Service configuration
        serviceAPI = UserDefaults.standard.string(forKey: "KikoServiceAPI") ?? ""
        organizationId = UserDefaults.standard.string(forKey: "KikoOrganizationId") ?? ""
        developerName = UserDefaults.standard.string(forKey: "KikoDeveloperName") ?? ""
        forceConfigEndpoint = UserDefaults.standard.string(forKey: "KikoForceConfigEndpoint") ?? ""
        
        // Load feature flags
        enableMultiModalInput = UserDefaults.standard.object(forKey: "KikoFeatureFlag_enableMultiModalInput") as? Bool ?? true
        enablePDFFileUpload = UserDefaults.standard.object(forKey: "KikoFeatureFlag_enablePDFFileUpload") as? Bool ?? true
        multiAgent = UserDefaults.standard.object(forKey: "KikoFeatureFlag_multiAgent") as? Bool ?? true
        shouldBlockMicrophone = UserDefaults.standard.object(forKey: "KikoFeatureFlag_shouldBlockMicrophone") as? Bool ?? false
    }
    
    // MARK: - Helper Methods
    
    /// Create theme manager instance based on current theme mode setting
    func createThemeManager() -> AgentforceThemeManager {
        BrandTheme.themeManager(mode: themeMode)
    }
    
    /// Create feature flag settings from current configuration
    func createFeatureFlagSettings() -> AgentforceFeatureFlagSettings {
        AgentforceFeatureFlagSettings(
            enableMultiModalInput: enableMultiModalInput,
            enablePDFFileUpload: enablePDFFileUpload,
            multiAgent: multiAgent,
            shouldBlockMicrophone: shouldBlockMicrophone,
            internalFlags: [:]
        )
    }
    
    /// Create ServiceDeploymentConfig from current settings
    /// Returns nil if required fields are empty or invalid
    func createServiceDeploymentConfig() -> ServiceAgentConfiguration? {
        let trimmedServiceAPI = serviceAPI.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOrgId = organizationId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDevName = developerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Return nil if any required field is empty
        guard !trimmedServiceAPI.isEmpty,
              !trimmedOrgId.isEmpty,
              !trimmedDevName.isEmpty else {
            return nil
        }
        
        return ServiceAgentConfiguration(
            esDeveloperName: trimmedDevName,
            organizationId: trimmedOrgId,
            serviceApiURL: trimmedServiceAPI,
            serviceUISettings: ServiceUISettings(),
            forceConfigEndPoint: forceConfigEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    /// Reset all settings to their default values
    func resetToDefaults() {
        themeMode = .system
        
        serviceAPI = ""
        organizationId = ""
        developerName = ""
        forceConfigEndpoint = ""
        
        // Get actual default values from SDK
        let defaultSettings = AgentforceFeatureFlagSettings()
        enableMultiModalInput = defaultSettings.enableMultiModalInput
        enablePDFFileUpload = defaultSettings.enablePDFFileUpload
        multiAgent = defaultSettings.multiAgent
        shouldBlockMicrophone = defaultSettings.shouldBlockMicrophone
    }
    
    /// Check if Service configuration is complete
    var isServiceConfigured: Bool {
        return createServiceDeploymentConfig() != nil
    }
}

