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
    
    // MARK: - Theme Configuration
    
    var themeMode: AgentforceThemeMode = .system {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: "PlantCareThemeMode")
        }
    }
    
    // MARK: - Service Configuration
    
    var serviceAPI: String = "" {
        didSet {
            UserDefaults.standard.set(serviceAPI, forKey: "PlantCareServiceAPI")
        }
    }
    
    var organizationId: String = "" {
        didSet {
            UserDefaults.standard.set(organizationId, forKey: "PlantCareOrganizationId")
        }
    }
    
    var developerName: String = "" {
        didSet {
            UserDefaults.standard.set(developerName, forKey: "PlantCareDeveloperName")
        }
    }
    
    // MARK: - Feature Flags
    
    var enableMultiModalInput: Bool = true {
        didSet {
            UserDefaults.standard.set(enableMultiModalInput, forKey: "PlantCareFeatureFlag_enableMultiModalInput")
        }
    }
    
    var enablePDFFileUpload: Bool = true {
        didSet {
            UserDefaults.standard.set(enablePDFFileUpload, forKey: "PlantCareFeatureFlag_enablePDFFileUpload")
        }
    }
    
    var multiAgent: Bool = true {
        didSet {
            UserDefaults.standard.set(multiAgent, forKey: "PlantCareFeatureFlag_multiAgent")
        }
    }
    
    var shouldBlockMicrophone: Bool = false {
        didSet {
            UserDefaults.standard.set(shouldBlockMicrophone, forKey: "PlantCareFeatureFlag_shouldBlockMicrophone")
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - UserDefaults Integration
    
    private func loadFromUserDefaults() {
        // Load theme configuration
        let themeModeString = UserDefaults.standard.string(forKey: "PlantCareThemeMode") ?? "system"
        themeMode = AgentforceThemeMode(rawValue: themeModeString) ?? .system
        
        // Load Service configuration
        serviceAPI = UserDefaults.standard.string(forKey: "PlantCareServiceAPI") ?? ""
        organizationId = UserDefaults.standard.string(forKey: "PlantCareOrganizationId") ?? ""
        developerName = UserDefaults.standard.string(forKey: "PlantCareDeveloperName") ?? ""
        
        // Load feature flags
        enableMultiModalInput = UserDefaults.standard.object(forKey: "PlantCareFeatureFlag_enableMultiModalInput") as? Bool ?? true
        enablePDFFileUpload = UserDefaults.standard.object(forKey: "PlantCareFeatureFlag_enablePDFFileUpload") as? Bool ?? true
        multiAgent = UserDefaults.standard.object(forKey: "PlantCareFeatureFlag_multiAgent") as? Bool ?? true
        shouldBlockMicrophone = UserDefaults.standard.object(forKey: "PlantCareFeatureFlag_shouldBlockMicrophone") as? Bool ?? false
    }
    
    // MARK: - Helper Methods
    
    /// Create theme manager instance based on current theme mode setting
    func createThemeManager() -> AgentforceThemeManager {
        CustomizableThemeManager(themeMode: themeMode)
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
            serviceUISettings: ServiceUISettings()
        )
    }
    
    /// Reset all settings to their default values
    func resetToDefaults() {
        themeMode = .system
        
        serviceAPI = ""
        organizationId = ""
        developerName = ""
        
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

