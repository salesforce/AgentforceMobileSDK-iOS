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
import SwiftUI
import AgentforceSDK
import Observation

/// A customizable theme manager that wraps the default Agentforce theme manager
/// to allow runtime color customization for demo purposes.
@Observable
class CustomizableThemeManager: AgentforceThemeManager {    
    var customAgentNames: [AgentforceSDK.AgentNameType : String?] = [:]
    
    var avatarConfiguration: [AgentforceSDK.AvatarType : Image?] = [:]
    
    /// The underlying default theme manager
    private var defaultThemeManager: AgentforceDefaultThemeManager
    
    /// Custom light mode color overrides
    private var customLightModeColors: [String: Color] = [:]
    
    /// Custom dark mode color overrides
    private var customDarkModeColors: [String: Color] = [:]
    
    /// Current theme mode
    private var currentThemeMode: AgentforceThemeMode
    
    /// Current dynamic fonts setting
    private var currentDynamicFonts: Bool
    
    /// Currently selected theme preset name (nil if custom)
    private var currentPresetName: String?
    
    /// Initializer that sets up the customizable theme manager
    /// - Parameters:
    ///   - themeMode: The theme mode (light, dark, or system)
    ///   - dynamicFonts: Whether to use dynamic fonts
    ///   - customLightColors: Custom light mode color overrides
    ///   - customDarkColors: Custom dark mode color overrides
    init(
        themeMode: AgentforceThemeMode = .light,
        dynamicFonts: Bool = false,
        customLightColors: [String: Color] = [:],
        customDarkColors: [String: Color] = [:]
    ) {
        self.currentThemeMode = themeMode
        self.currentDynamicFonts = dynamicFonts
        self.defaultThemeManager = AgentforceDefaultThemeManager(themeMode: themeMode, dynamicFonts: dynamicFonts)
        self.customLightModeColors = customLightColors
        self.customDarkModeColors = customDarkColors
        
        // Load saved custom colors if no custom colors were provided
        if customLightColors.isEmpty, customDarkColors.isEmpty {
            loadCustomColors()
        }
        
        // Load saved preset name
        self.currentPresetName = UserDefaults.standard.string(forKey: "PlantCare_currentPresetName")
    }
    
    /// Load custom color overrides from UserDefaults
    private func loadCustomColors() {
        let decoder = JSONDecoder()
        
        // Load light mode colors
        if let lightData = UserDefaults.standard.data(forKey: "PlantCare_customLightColors"),
           let lightHexColors = try? decoder.decode([String: String].self, from: lightData) {
            customLightModeColors = lightHexColors.compactMapValues { Color(hex: $0) }
        }
        
        // Load dark mode colors
        if let darkData = UserDefaults.standard.data(forKey: "PlantCare_customDarkColors"),
           let darkHexColors = try? decoder.decode([String: String].self, from: darkData) {
            customDarkModeColors = darkHexColors.compactMapValues { Color(hex: $0) }
        }
    }
    
    /// Delegate most properties to the default theme manager
    var overrideColorSchemeWithSystem: Bool {
        defaultThemeManager.overrideColorSchemeWithSystem
    }
    
    var colorScheme: ColorScheme {
        get { defaultThemeManager.colorScheme }
        set { defaultThemeManager.colorScheme = newValue }
    }
    
    var dynamicFonts: Bool {
        get { defaultThemeManager.dynamicFonts }
        set { defaultThemeManager.dynamicFonts = newValue }
    }
    
    var dimensions: AgentforceTheme.Dimensions {
        defaultThemeManager.dimensions
    }
    
    var shapes: AgentforceTheme.Shapes {
        defaultThemeManager.shapes
    }
    
    var fonts: AgentforceTheme.Fonts {
        defaultThemeManager.fonts
    }
    
    /// Override the colors property to return our customizable colors
    var colors: AgentforceTheme.Colors {
        CustomizableColors(
            customColors: colorScheme == .light ? customLightModeColors : customDarkModeColors,
            defaultColors: defaultThemeManager.colors,
            colorScheme: colorScheme
        )
    }
    
    /// Get the default color for a token by creating a temporary theme manager
    private func getDefaultColor(token: String, isLightMode: Bool) -> Color {
        let tempTheme = AgentforceDefaultThemeManager(themeMode: isLightMode ? .light : .dark)
        
        switch token {
        case "surface1": return tempTheme.colors.surface1
        case "surface2": return tempTheme.colors.surface2
        case "onSurface1": return tempTheme.colors.onSurface1
        case "onSurface2": return tempTheme.colors.onSurface2
        case "onSurface3": return tempTheme.colors.onSurface3
        case "surfaceContainer1": return tempTheme.colors.surfaceContainer1
        case "surfaceContainer2": return tempTheme.colors.surfaceContainer2
        case "surfaceContainer3": return tempTheme.colors.surfaceContainer3
        case "border1": return tempTheme.colors.border1
        case "accent1": return tempTheme.colors.accent1
        case "accent2": return tempTheme.colors.accent2
        case "accent3": return tempTheme.colors.accent3
        case "accent4": return tempTheme.colors.accent4
        case "accent5": return tempTheme.colors.accent5
        case "accentContainer1": return tempTheme.colors.accentContainer1
        case "onAccent1": return tempTheme.colors.onAccent1
        case "error1": return tempTheme.colors.error1
        case "errorContainer1": return tempTheme.colors.errorContainer1
        case "onError1": return tempTheme.colors.onError1
        case "borderError1": return tempTheme.colors.borderError1
        case "disabledContainer1": return tempTheme.colors.disabledContainer1
        case "onDisabled1": return tempTheme.colors.onDisabled1
        case "onDisabled2": return tempTheme.colors.onDisabled2
        default: return tempTheme.colors.surface1
        }
    }
    
    /// Apply a theme preset by setting all colors from the preset
    /// - Parameter preset: The theme preset to apply
    /// - Note: This does NOT save to UserDefaults. Call saveCustomColors() separately to persist.
    func applyThemePreset(_ preset: ThemePreset) {
        // Apply light mode colors
        for (tokenName, color) in preset.lightColors {
            customLightModeColors[tokenName] = color
        }
        
        // Apply dark mode colors
        for (tokenName, color) in preset.darkColors {
            customDarkModeColors[tokenName] = color
        }
        
        // Set current preset name
        currentPresetName = preset.name
        
        // Don't save yet - let the UI decide when to persist
    }
    
    /// Save custom color overrides to UserDefaults
    func saveCustomColors() {
        // Only save colors that actually differ from defaults (using hex comparison)
        var lightHexColors: [String: String] = [:]
        for (tokenName, color) in customLightModeColors {
            guard let hex = color.toHex(),
                  let defaultHex = getDefaultColor(token: tokenName, isLightMode: true).toHex() else {
                continue
            }
            // Only include if different from default
            if hex.uppercased() != defaultHex.uppercased() {
                lightHexColors[tokenName] = hex
            }
        }
        
        var darkHexColors: [String: String] = [:]
        for (tokenName, color) in customDarkModeColors {
            guard let hex = color.toHex(),
                  let defaultHex = getDefaultColor(token: tokenName, isLightMode: false).toHex() else {
                continue
            }
            // Only include if different from default
            if hex.uppercased() != defaultHex.uppercased() {
                darkHexColors[tokenName] = hex
            }
        }
        
        let encoder = JSONEncoder()
        
        // Save or clear light colors
        if lightHexColors.isEmpty {
            UserDefaults.standard.removeObject(forKey: "PlantCare_customLightColors")
        } else if let lightData = try? encoder.encode(lightHexColors) {
            UserDefaults.standard.set(lightData, forKey: "PlantCare_customLightColors")
        }
        
        // Save or clear dark colors
        if darkHexColors.isEmpty {
            UserDefaults.standard.removeObject(forKey: "PlantCare_customDarkColors")
        } else if let darkData = try? encoder.encode(darkHexColors) {
            UserDefaults.standard.set(darkData, forKey: "PlantCare_customDarkColors")
        }
        
        // Save current preset name
        if let presetName = currentPresetName {
            UserDefaults.standard.set(presetName, forKey: "PlantCare_currentPresetName")
        } else {
            UserDefaults.standard.removeObject(forKey: "PlantCare_currentPresetName")
        }
    }
    
    /// Get the current theme mode
    var themeMode: AgentforceThemeMode {
        currentThemeMode
    }
    
    /// Get custom light color for a specific token
    /// - Parameter token: The color token
    /// - Returns: Custom light color or default if not customized
    func getLightColor(for token: ColorToken) -> Color {
        customLightModeColors[token.rawValue] ?? getDefaultColor(token: token.rawValue, isLightMode: true)
    }
    
    /// Get custom dark color for a specific token
    /// - Parameter token: The color token
    /// - Returns: Custom dark color or default if not customized
    func getDarkColor(for token: ColorToken) -> Color {
        customDarkModeColors[token.rawValue] ?? getDefaultColor(token: token.rawValue, isLightMode: false)
    }
    
    /// Set light mode color for a specific token
    /// - Parameters:
    ///   - color: The color to set
    ///   - token: The color token
    func setLightColor(_ color: Color, for token: ColorToken) {
        customLightModeColors[token.rawValue] = color
        // Clear preset name when manually customizing colors
        currentPresetName = nil
    }
    
    /// Set dark mode color for a specific token
    /// - Parameters:
    ///   - color: The color to set
    ///   - token: The color token
    func setDarkColor(_ color: Color, for token: ColorToken) {
        customDarkModeColors[token.rawValue] = color
        // Clear preset name when manually customizing colors
        currentPresetName = nil
    }
    
    /// Reset a specific token to its default color
    /// - Parameters:
    ///   - token: The color token to reset
    ///   - scheme: The color scheme to reset (light or dark)
    func resetToken(_ token: ColorToken, for scheme: ColorScheme) {
        if scheme == .light {
            customLightModeColors.removeValue(forKey: token.rawValue)
        } else {
            customDarkModeColors.removeValue(forKey: token.rawValue)
        }
        // Clear preset name when manually resetting tokens
        currentPresetName = nil
    }
    
    /// Reset all colors to defaults
    /// - Note: This does NOT save to UserDefaults. Call saveCustomColors() separately to persist.
    func resetAllColors() {
        customLightModeColors.removeAll()
        customDarkModeColors.removeAll()
        currentPresetName = nil
        
        // Don't clear UserDefaults yet - let the UI decide when to persist
    }
    
    /// Get the current theme preset name
    /// - Returns: The name of the currently applied preset, or nil if using custom colors
    var currentThemePresetName: String? {
        currentPresetName
    }
    
    /// Check if the current theme is a preset or custom
    /// - Returns: True if using a preset, false if custom
    var isUsingPreset: Bool {
        currentPresetName != nil
    }
    
    /// Get the number of custom colors currently applied
    /// - Returns: Total count of custom light and dark mode colors
    var customColorCount: Int {
        customLightModeColors.count + customDarkModeColors.count
    }
}

