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

// MARK: - Color Comparison Helper

extension Color {
    /// Compare two colors by their hex values (immune to floating-point precision issues)
    func isEqualTo(_ other: Color) -> Bool {
        guard let hex1 = toHex()?.uppercased(),
              let hex2 = other.toHex()?.uppercased() else {
            return false
        }
        return hex1 == hex2
    }
}

// MARK: - ColorToken Extension

extension ColorToken {
    /// Returns the color for this token from the provided theme colors
    func color(from colors: AgentforceTheme.Colors) -> Color {
        switch self {
        // Core surface colors
        case .surface1: return colors.surface1
        case .surface2: return colors.surface2
        case .surfaceContainer1: return colors.surfaceContainer1
        case .surfaceContainer2: return colors.surfaceContainer2
        case .surfaceContainer3: return colors.surfaceContainer3
        // Essential text colors
        case .onSurface1: return colors.onSurface1
        case .onSurface2: return colors.onSurface2
        case .onSurface3: return colors.onSurface3
        // Interactive colors
        case .accent1: return colors.accent1
        case .accent2: return colors.accent2
        case .accent3: return colors.accent3
        case .accent4: return colors.accent4
        case .accent5: return colors.accent5
        case .accent6: return colors.accent6
        case .accent7: return colors.accent7
        case .accent8: return colors.accent8
        case .accentContainer1: return colors.accentContainer1
        case .onAccent1: return colors.onAccent1
        case .chatHeaderBackground: return colors.chatHeaderBackground
        // Feedback colors
        case .error1: return colors.error1
        case .errorContainer1: return colors.errorContainer1
        case .onError1: return colors.onError1
        // Border colors
        case .border1: return colors.border1
        case .borderError1: return colors.borderError1
        // Disabled state colors
        case .disabledContainer1: return colors.disabledContainer1
        case .onDisabled1: return colors.onDisabled1
        case .onDisabled2: return colors.onDisabled2
        }
    }
    
    /// Returns the default color for this token based on the color scheme
    func defaultColor(for colorScheme: ColorScheme) -> Color {
        let defaultManager = colorScheme == .light
            ? AgentforceDefaultThemeManager(themeMode: .light)
            : AgentforceDefaultThemeManager(themeMode: .dark)
        return color(from: defaultManager.colors)
    }
}

struct AdvancedColorPickerView: View {
    @Bindable var settings: PlantCareSettings
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColorScheme: ColorScheme = .light
    @State private var showingPresets = false
    @State private var searchText = ""
    @State private var expandedCategories: Set<String> = ["Surface Colors", "Text & Icons", "Accent Colors"]
    @State private var hasUnsavedChanges = false
    @State private var currentSelectedPreset: String? = nil
    @State private var activeThemeName: String = "Default"
    @State private var isSaving = false
    @State private var showingSaveConfirmation = false
    
    @State private var refreshTrigger: Bool = false
    @State private var themeManager: CustomizableThemeManager
    
    // Computed property for custom color count
    private var customColorCount: Int {
        themeManager.customColorCount
    }
    
    init(settings: PlantCareSettings) {
        self.settings = settings
        let themeManager = CustomizableThemeManager(themeMode: settings.themeMode)
        self._themeManager = State(initialValue: themeManager)
    }
    
    private var filteredCategories: [ColorCategory] {
        if searchText.isEmpty {
            return ColorCategory.allCases
        } else {
            return ColorCategory.allCases.filter { category in
                category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                category.tokens.contains { token in
                    token.displayName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section
                        headerSection
                        
                        // Search section
                        searchSection
                        
                        // Color categories
                        LazyVStack(spacing: 20) {
                            ForEach(filteredCategories, id: \.rawValue) { category in
                                ColorCategoryCard(
                                    category: category,
                                    colorScheme: selectedColorScheme,
                                    themeManager: themeManager,
                                    isExpanded: expandedCategories.contains(category.rawValue),
                                    refreshTrigger: refreshTrigger,
                                    onToggleExpanded: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            if expandedCategories.contains(category.rawValue) {
                                                expandedCategories.remove(category.rawValue)
                                            } else {
                                                expandedCategories.insert(category.rawValue)
                                            }
                                        }
                                    },
                                    onUpdate: {
                                        hasUnsavedChanges = true
                                    }
                                )
                            }
                        }
                        
                        // Reset section
                        if customColorCount > 0 {
                            resetSection
                        }
                        
                        // Bottom spacing
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Theme Studio")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("Customize your experience")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button("Presets") {
                            showingPresets = true
                        }
                        .buttonStyle(isPrimary: false)
                        
                        Button(action: {
                            saveChangesWithFeedback()
                        }) {
                            HStack(spacing: 6) {
                                if isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else if showingSaveConfirmation {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                
                                Text(showingSaveConfirmation ? "Saved!" : "Save")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(
                            isPrimary: true,
                            isEnabled: hasUnsavedChanges && !isSaving,
                            isDestructive: false
                        )
                        .disabled(!hasUnsavedChanges || isSaving)
                        .scaleEffect(isSaving ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSaving)
                    }
                }
            }
            .sheet(isPresented: $showingPresets) {
                SimpleThemePresetsView(
                    themeManager: themeManager,
                    currentSelectedPreset: $currentSelectedPreset
                ) {
                    // Trigger refresh in all child rows to load new preset colors
                    refreshTrigger.toggle()
                    hasUnsavedChanges = true
                    showingPresets = false
                    refreshActiveThemeName()
                }
            }
            .onAppear {
                refreshActiveThemeName()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Current theme indicator (selected preset or Default)
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.65)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.blue.opacity(0.25), radius: 6, x: 0, y: 3)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Theme")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            Text(activeThemeName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            if customColorCount > 0 {
                                Text("\(customColorCount) custom")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.orange.opacity(0.15)))
                            }
                        }
                }
                Spacer()
                // Quick status dot for selected color scheme
                HStack(spacing: 6) {
                    Circle()
                        .fill(selectedColorScheme == .light ? Color.orange : Color.indigo)
                        .frame(width: 8, height: 8)
                    Text(selectedColorScheme == .light ? "Light" : "Dark")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
            )
            // Mode selection cards
            HStack(spacing: 16) {
                // Light mode card
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedColorScheme = .light
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 2) {
                            Text("Light")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Light mode token colors")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(
                                color: selectedColorScheme == .light ? Color.orange.opacity(0.3) : Color.black.opacity(0.06),
                                radius: selectedColorScheme == .light ? 8 : 4,
                                x: 0,
                                y: selectedColorScheme == .light ? 4 : 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        selectedColorScheme == .light ? Color.orange.opacity(0.4) : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                    .scaleEffect(selectedColorScheme == .light ? 1.02 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Dark mode card
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedColorScheme = .dark
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 2) {
                            Text("Dark")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Dark mode token colors")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(
                                color: selectedColorScheme == .dark ? Color.indigo.opacity(0.3) : Color.black.opacity(0.06),
                                radius: selectedColorScheme == .dark ? 8 : 4,
                                x: 0,
                                y: selectedColorScheme == .dark ? 4 : 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        selectedColorScheme == .dark ? Color.indigo.opacity(0.4) : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                    .scaleEffect(selectedColorScheme == .dark ? 1.02 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Stats card
            if customColorCount > 0 {
                HStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(customColorCount) customized")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("color tokens")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if hasUnsavedChanges {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                            Text("Unsaved changes")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
            }
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search color tokens...", text: $searchText)
                .font(.body)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Reset Section
    
    private var resetSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset to defaults")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Restore all colors to their original values")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button("Reset All Colors") {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    // Reset all colors in the theme manager (clears in-memory state only)
                    themeManager.resetAllColors()
                    
                    // Trigger refresh in all child rows to reset their UI state
                    refreshTrigger.toggle()
                    
                    // Update UI state - mark as having changes to save
                    hasUnsavedChanges = true
                    activeThemeName = "Default"
                    currentSelectedPreset = nil
                }
            }
            .buttonStyle(isPrimary: false, isDestructive: true)
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Private Methods
    
    private func refreshActiveThemeName() {
        if let presetName = themeManager.currentThemePresetName {
            activeThemeName = presetName
        } else if customColorCount > 0 {
            activeThemeName = "Custom"
        } else {
            activeThemeName = "Default"
        }
    }
    
    private func detectActivePresetName() -> String? {
        for preset in ThemePreset.allPresets {
            var matches = true
            for token in ColorToken.allCases {
                guard
                    let lightHex = themeManager.getLightColor(for: token).toHex()?.uppercased(),
                    let presetLightHex = preset.lightColors[token.rawValue]?.toHex()?.uppercased(),
                    let darkHex = themeManager.getDarkColor(for: token).toHex()?.uppercased(),
                    let presetDarkHex = preset.darkColors[token.rawValue]?.toHex()?.uppercased()
                else { matches = false; break }
                if lightHex != presetLightHex || darkHex != presetDarkHex { matches = false; break }
            }
            if matches { return preset.name }
        }
        return nil
    }
    
    private func saveChanges() {
        // Force save the current theme manager state
        themeManager.saveCustomColors()
        
        hasUnsavedChanges = false
        
        triggerNewAgentforceSession()
    }
    
    private func saveChangesWithFeedback() {
        // Immediate haptic feedback when button is pressed
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isSaving = true
        
        withAnimation(.easeInOut(duration: 0.3)) {
            saveChanges()
        }
        
        // Show loading for a moment, then show confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isSaving = false
                showingSaveConfirmation = true
            }
            
            // Success haptic feedback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            // Show "Saved!" confirmation for a moment, then hide it
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showingSaveConfirmation = false
                }
            }
        }
    }
    
    private func triggerNewAgentforceSession() {
        settings.onNeedsReinitialize?()
    }
}

// MARK: - Color Category Card

struct ColorCategoryCard: View {
    let category: ColorCategory
    let colorScheme: ColorScheme
    let themeManager: CustomizableThemeManager
    let isExpanded: Bool
    let refreshTrigger: Bool
    let onToggleExpanded: () -> Void
    let onUpdate: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Category header - Entire row is tappable
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(category.accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(category.accentColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle()) // Ensures entire area is tappable
            .onTapGesture {
                onToggleExpanded()
            }
            
            // Expanded content
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.tokens, id: \.rawValue) { token in
                        ColorTokenRow(
                            token: token,
                            colorScheme: colorScheme,
                            themeManager: themeManager,
                            refreshTrigger: refreshTrigger,
                            onUpdate: onUpdate
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(
                    Rectangle()
                        .fill(category.accentColor.opacity(0.02))
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isExpanded ? category.accentColor.opacity(0.2) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Color Token Row

struct ColorTokenRow: View {
    let token: ColorToken
    let colorScheme: ColorScheme
    let themeManager: CustomizableThemeManager
    let refreshTrigger: Bool
    let onUpdate: () -> Void
    
    @State private var currentColor: Color
    @State private var originalColor: Color
    
    // Computed property - always in sync with currentColor vs originalColor
    private var isCustomized: Bool {
        !currentColor.isEqualTo(originalColor)
    }
    
    init(token: ColorToken, colorScheme: ColorScheme, themeManager: CustomizableThemeManager, refreshTrigger: Bool, onUpdate: @escaping () -> Void) {
        self.token = token
        self.colorScheme = colorScheme
        self.themeManager = themeManager
        self.refreshTrigger = refreshTrigger
        self.onUpdate = onUpdate
        
        let actualColor = colorScheme == .light
            ? themeManager.getLightColor(for: token)
            : themeManager.getDarkColor(for: token)
        self._currentColor = State(initialValue: actualColor)
        
        // Store original color for revert functionality
        let originalColor = token.defaultColor(for: colorScheme)
        self._originalColor = State(initialValue: originalColor)
    }
    
    var body: some View {
        Button(action: {
            // Open color picker when row is tapped
        }) {
            HStack(spacing: 0) {
                // Main content area - spans full width
                VStack(alignment: .leading, spacing: 6) {
                    // Top row with token name and badges
                    HStack(spacing: 8) {
                        Text(token.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if isCustomized {
                            Text("CUSTOM")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                                .transition(.scale.combined(with: .opacity))
                                .id("custom-badge-\(token.rawValue)")
                        }
                        
                        Spacer()
                    }
                    
                    // Bottom row with color info, reset button, and picker
                    HStack(spacing: 12) {
                        // Current color display
                        HStack(spacing: 8) {
                            // Small color indicator
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(currentColor)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                )
                            
                            // Hex value
                            if let hex = currentColor.toHex() {
                                Text(hex.uppercased())
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        // Reset button and color picker side by side
                        HStack(spacing: 8) {
                            // Reset button (only show if customized)
                            if isCustomized {
                                Button(action: resetColor) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.orange)
                                        .frame(width: 28, height: 28)
                                        .background(
                                            Circle()
                                                .fill(Color.orange.opacity(0.1))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.scale.combined(with: .opacity))
                                .id("revert-button-\(token.rawValue)")
                            }
                            
                            // Color picker (no text label)
                            ColorPicker("Token Color", selection: $currentColor, supportsOpacity: true)
                                .labelsHidden()
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: currentColor) { oldValue, newValue in
            if colorScheme == .light {
                themeManager.setLightColor(newValue, for: token)
            } else {
                themeManager.setDarkColor(newValue, for: token)
            }
            // Notify parent immediately
            onUpdate()
        }
        .onChange(of: colorScheme) { oldScheme, newScheme in
            let newColor = newScheme == .light
                ? themeManager.getLightColor(for: token)
                : themeManager.getDarkColor(for: token)
            currentColor = newColor
            
            // Update original color for new scheme
            originalColor = token.defaultColor(for: newScheme)
            // Notify parent to update state
            onUpdate()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
        )
        .onAppear {
            // Sync color from theme manager
            let latestColor = colorScheme == .light
                ? themeManager.getLightColor(for: token)
                : themeManager.getDarkColor(for: token)
            if !currentColor.isEqualTo(latestColor) {
                currentColor = latestColor
            }
        }
        .onChange(of: refreshTrigger) { oldValue, newValue in
            // When refresh is triggered (reset, preset applied, or reopen), sync from theme manager
            let latestColor = colorScheme == .light
                ? themeManager.getLightColor(for: token)
                : themeManager.getDarkColor(for: token)
            currentColor = latestColor
        }
    }
    
    private func resetColor() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            // Reset token for the current color scheme only
            themeManager.resetToken(token, for: colorScheme)
            
            // Update current color to the default for current scheme
            currentColor = token.defaultColor(for: colorScheme)
            
            // Notify parent to update state
            onUpdate()
        }
    }
}

// MARK: - Simple Theme Presets View

struct SimpleThemePresetsView: View {
    let themeManager: CustomizableThemeManager
    @Binding var currentSelectedPreset: String?
    let onDismiss: () -> Void
    
    private let allPresets = ThemePreset.allPresets
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(allPresets) { preset in
                        SimpleThemePresetCard(
                            preset: preset,
                            isSelected: currentSelectedPreset == preset.name,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentSelectedPreset = preset.name
                                    themeManager.applyThemePreset(preset)
                                    onDismiss()
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Theme Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Simple Theme Preset Card

struct SimpleThemePresetCard: View {
    let preset: ThemePreset
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with brand logo and organization
            HStack {
                // Brand Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [preset.primaryColor, preset.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: preset.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text(brandInitials(preset.name))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(preset.primaryColor)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            
            // Theme name
            Text(preset.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Organization badge
            Text(preset.organization)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(preset.primaryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(preset.primaryColor.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(preset.primaryColor.opacity(0.3), lineWidth: 0.5)
                        )
                )
            
            // Enhanced color preview
            HStack(spacing: 3) {
                ForEach(Array(preset.previewColors.prefix(4).enumerated()), id: \.offset) { index, color in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(color)
                        .frame(height: 20)
                }
            }
            
            // Description
            Text(preset.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(
                    color: isSelected ? preset.primaryColor.opacity(0.2) : .black.opacity(0.06),
                    radius: isSelected ? 12 : 6,
                    x: 0,
                    y: isSelected ? 6 : 3
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected
                                ? LinearGradient(colors: [preset.primaryColor, preset.primaryColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 2 : 0
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
    
    private func brandInitials(_ name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
}

// MARK: - Compact Button Styles

struct CompactDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.red)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extension

extension View {
    func buttonStyle(isPrimary: Bool = true, isEnabled: Bool = true, isDestructive: Bool = false) -> some View {
        font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(
                isDestructive ? .white :
                isPrimary ? .white :
                isEnabled ? .blue : .secondary
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isDestructive {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                    } else if isPrimary {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.systemGray6))
                    }
                }
            )
    }
}

#Preview {
    let compositionRoot = CompositionRoot()
    return AdvancedColorPickerView(settings: compositionRoot.settings)
}
