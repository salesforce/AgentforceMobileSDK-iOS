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

/// A customizable theme manager that extends the default Agentforce theme manager
/// to allow runtime color customization for demo purposes.
///
/// Subclassing `AgentforceDefaultThemeManager` and overriding its palette hooks is the
/// SDK's supported customization pattern; fonts, dimensions, shapes, icons, and display
/// names are inherited from the default theme.
nonisolated final class CustomizableThemeManager: AgentforceDefaultThemeManager {
    /// Observation-tracked custom color overrides and preset selection
    private let store: CustomColorStore
    
    /// Current theme mode
    private let currentThemeMode: AgentforceThemeMode
    
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
        self.store = CustomColorStore(light: customLightColors, dark: customDarkColors)
        super.init(themeMode: themeMode, dynamicFonts: dynamicFonts)
        
        // Load saved custom colors if no custom colors were provided
        if customLightColors.isEmpty, customDarkColors.isEmpty {
            loadCustomColors()
        }
        
        // Load saved preset name
        store.presetName = UserDefaults.standard.string(forKey: "PlantCare_currentPresetName")
    }
    
    /// Load custom color overrides from UserDefaults
    private func loadCustomColors() {
        store.light = Self.loadColors(forKey: "PlantCare_customLightColors")
        store.dark = Self.loadColors(forKey: "PlantCare_customDarkColors")
    }
    
    /// Decode saved hex colors, dropping tokens that are no longer customizable
    private static func loadColors(forKey key: String) -> [String: Color] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let hexColors = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return hexColors
            .filter { ColorToken(rawValue: $0.key) != nil }
            .compactMapValues { Color(hex: $0) }
    }
    
    /// Light mode palette with custom color overrides
    override var lightModeColors: AgentforceColorPalette {
        CustomizableLightColors(store: store)
    }
    
    /// Dark mode palette with custom color overrides
    override var darkModeColors: AgentforceColorPalette {
        CustomizableDarkColors(store: store)
    }
    
    /// Apply a theme preset by setting all colors from the preset
    /// - Parameter preset: The theme preset to apply
    /// - Note: This does NOT save to UserDefaults. Call saveCustomColors() separately to persist.
    func applyThemePreset(_ preset: ThemePreset) {
        // Apply light mode colors
        for (tokenName, color) in preset.lightColors {
            store.light[tokenName] = color
        }
        
        // Apply dark mode colors
        for (tokenName, color) in preset.darkColors {
            store.dark[tokenName] = color
        }
        
        // Set current preset name
        store.presetName = preset.name
        
        // Don't save yet - let the UI decide when to persist
    }
    
    /// Hex values of the custom colors that differ from the SDK defaults
    private static func customHexColors(_ colors: [String: Color], isLightMode: Bool) -> [String: String] {
        var hexColors: [String: String] = [:]
        for (tokenName, color) in colors {
            guard let token = ColorToken(rawValue: tokenName),
                  let hex = color.toHex(),
                  let defaultHex = token.defaultColor(isLightMode: isLightMode).toHex() else {
                continue
            }
            // Only include if different from default
            if hex.uppercased() != defaultHex.uppercased() {
                hexColors[tokenName] = hex
            }
        }
        return hexColors
    }
    
    /// Save custom color overrides to UserDefaults
    func saveCustomColors() {
        // Only save colors that actually differ from defaults (using hex comparison)
        let lightHexColors = Self.customHexColors(store.light, isLightMode: true)
        let darkHexColors = Self.customHexColors(store.dark, isLightMode: false)
        
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
        if let presetName = store.presetName {
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
        store.light[token.rawValue] ?? token.defaultColor(isLightMode: true)
    }
    
    /// Get custom dark color for a specific token
    /// - Parameter token: The color token
    /// - Returns: Custom dark color or default if not customized
    func getDarkColor(for token: ColorToken) -> Color {
        store.dark[token.rawValue] ?? token.defaultColor(isLightMode: false)
    }
    
    /// Set light mode color for a specific token
    /// - Parameters:
    ///   - color: The color to set
    ///   - token: The color token
    func setLightColor(_ color: Color, for token: ColorToken) {
        store.light[token.rawValue] = color
        // Clear preset name when manually customizing colors
        store.presetName = nil
    }
    
    /// Set dark mode color for a specific token
    /// - Parameters:
    ///   - color: The color to set
    ///   - token: The color token
    func setDarkColor(_ color: Color, for token: ColorToken) {
        store.dark[token.rawValue] = color
        // Clear preset name when manually customizing colors
        store.presetName = nil
    }
    
    /// Reset a specific token to its default color
    /// - Parameters:
    ///   - token: The color token to reset
    ///   - scheme: The color scheme to reset (light or dark)
    func resetToken(_ token: ColorToken, for scheme: ColorScheme) {
        if scheme == .light {
            store.light.removeValue(forKey: token.rawValue)
        } else {
            store.dark.removeValue(forKey: token.rawValue)
        }
        // Clear preset name when manually resetting tokens
        store.presetName = nil
    }
    
    /// Reset all colors to defaults
    /// - Note: This does NOT save to UserDefaults. Call saveCustomColors() separately to persist.
    func resetAllColors() {
        store.light.removeAll()
        store.dark.removeAll()
        store.presetName = nil
        
        // Don't clear UserDefaults yet - let the UI decide when to persist
    }
    
    /// Get the current theme preset name
    /// - Returns: The name of the currently applied preset, or nil if using custom colors
    var currentThemePresetName: String? {
        store.presetName
    }
    
    /// Check if the current theme is a preset or custom
    /// - Returns: True if using a preset, false if custom
    var isUsingPreset: Bool {
        store.presetName != nil
    }
    
    /// Get the number of custom colors currently applied
    /// - Returns: Total count of custom light and dark mode colors
    var customColorCount: Int {
        store.light.count + store.dark.count
    }
}
