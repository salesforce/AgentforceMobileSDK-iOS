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

    // MARK: - Guest Auth Defaults  —  ⚙️ CONFIGURE THE AGENT HERE (build time)
    //
    // Paste your org's connection details between the quotes below to launch the app
    // already pointed at your agent, without typing them into the in-app Settings sheet
    // on every run. The My Domain URL and Agent ID are both required to start a
    // conversation; the SFAP URL can stay on the public-gateway default.
    //
    // These ship blank so the repo carries no org-specific config — fill them in for
    // local development, but don't commit real values.
    //
    // Note: these are *seed* defaults. They apply on a fresh install, or whenever the
    // matching field in Settings is left blank. A value entered in the in-app Settings
    // sheet is saved to UserDefaults and takes precedence on later launches — so if you
    // change a default here after already running the app, update the field in Settings
    // too or delete the app to clear its saved settings.
    static let defaultForceConfigEndpoint = ""                // e.g. "https://mycompany.my.salesforce.com"
    static let defaultAgentId = ""                            // your 18-char Agent ID, e.g. "0Xx…"
    static let defaultSFAPURL = "https://api.salesforce.com"  // public API gateway — usually leave as-is

    // MARK: - Theme Configuration

    var themeMode: AgentforceThemeMode = .system {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: "KikoThemeMode")
        }
    }

    // MARK: - Guest Auth Configuration

    /// Org My Domain URL (the "force config endpoint"), e.g. https://mycompany.my.salesforce.com.
    /// Guest auth resolves everything else from here.
    var forceConfigEndpoint: String = KikoSettings.defaultForceConfigEndpoint {
        didSet {
            UserDefaults.standard.set(forceConfigEndpoint, forKey: "KikoForceConfigEndpoint")
        }
    }

    /// The Agentforce Agent ID the conversation is started against.
    var agentId: String = KikoSettings.defaultAgentId {
        didSet {
            UserDefaults.standard.set(agentId, forKey: "KikoAgentId")
        }
    }

    /// Salesforce API gateway URL. Leave blank in Settings to use `defaultSFAPURL`.
    var sfapURL: String = "" {
        didSet {
            UserDefaults.standard.set(sfapURL, forKey: "KikoSFAPURL")
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
    
    /// Returns the stored string for `key`, or `default` when it is missing or empty.
    private func storedValue(forKey key: String, default fallback: String) -> String {
        let value = UserDefaults.standard.string(forKey: key) ?? ""
        return value.isEmpty ? fallback : value
    }

    private func loadFromUserDefaults() {
        // Load theme configuration
        let themeModeString = UserDefaults.standard.string(forKey: "KikoThemeMode") ?? "system"
        themeMode = AgentforceThemeMode(rawValue: themeModeString) ?? .system

        // Load guest auth configuration. A missing or empty stored value falls back to
        // the hardcoded default so the app stays configured out of the box.
        forceConfigEndpoint = storedValue(forKey: "KikoForceConfigEndpoint", default: KikoSettings.defaultForceConfigEndpoint)
        agentId = storedValue(forKey: "KikoAgentId", default: KikoSettings.defaultAgentId)
        // SFAP URL is stored as-entered (blank allowed); `effectiveSFAPURL` applies the fallback.
        sfapURL = UserDefaults.standard.string(forKey: "KikoSFAPURL") ?? ""

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
    
    /// Create feature flag settings from current configuration.
    ///
    /// Voice is always enabled so the "Ask Kiko" mic can start a voice session, and
    /// two voice-mode enhancements ship on by default:
    ///  - **CallKit** (`enableVoiceCallKit`): the voice session registers as a system
    ///    call, so it appears in Recents, shows lock-screen controls, and keeps running
    ///    when the app is backgrounded. Requires the `voip` `UIBackgroundMode` (declared
    ///    on the app target); the SDK force-disables CallKit on the simulator.
    ///  - **Closed captions**: `defaultClosedCaptionsEnabled` sets the initial (first
    ///    launch) caption state to on, and the `enableClosedCaptions` internal flag is
    ///    the kill switch that must also be enabled for captions to appear at all.
    func createFeatureFlagSettings() -> AgentforceFeatureFlagSettings {
        AgentforceFeatureFlagSettings(
            enableMultiModalInput: enableMultiModalInput,
            enablePDFFileUpload: enablePDFFileUpload,
            multiAgent: multiAgent,
            shouldBlockMicrophone: shouldBlockMicrophone,
            enableVoice: true,
            enableVoiceCallKit: true,
            defaultClosedCaptionsEnabled: true,
            internalFlags: ["enableClosedCaptions": true]
        )
    }

    /// The SFAP gateway URL actually used, applying the public default when blank.
    var effectiveSFAPURL: String {
        let trimmed = sfapURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? KikoSettings.defaultSFAPURL : trimmed
    }

    /// Reset all settings to their default values
    func resetToDefaults() {
        themeMode = .system

        forceConfigEndpoint = KikoSettings.defaultForceConfigEndpoint
        agentId = KikoSettings.defaultAgentId
        sfapURL = ""

        // Get actual default values from SDK
        let defaultSettings = AgentforceFeatureFlagSettings()
        enableMultiModalInput = defaultSettings.enableMultiModalInput
        enablePDFFileUpload = defaultSettings.enablePDFFileUpload
        multiAgent = defaultSettings.multiAgent
        shouldBlockMicrophone = defaultSettings.shouldBlockMicrophone
    }

    /// Whether guest auth is configured: a valid My Domain URL and a non-empty Agent ID.
    var isConfigured: Bool {
        let domain = forceConfigEndpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let agent = agentId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !domain.isEmpty, !agent.isEmpty else { return false }
        return AgentforceAuthCredentials.isValidGuestURL(domain)
    }
}

