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

struct SettingsView: View {
    @Bindable var settings: PlantCareSettings
    @State private var showingResetConfirmation = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.themeColors) private var environmentColors
    
    // Get theme colors for the current scheme
    private var colors: PlantCareTheme.Colors {
        let effectiveScheme: ColorScheme
        switch settings.themeMode {
        case .light:
            effectiveScheme = .light
        case .dark:
            effectiveScheme = .dark
        case .system:
            effectiveScheme = systemColorScheme
        }
        return PlantCareTheme.Colors(colorScheme: effectiveScheme)
    }
    
    var body: some View {
        Form {
            // Theme Section
            Section {
                Picker("Theme Mode", selection: $settings.themeMode) {
                    Text("Light").tag(AgentforceThemeMode.light)
                    Text("Dark").tag(AgentforceThemeMode.dark)
                    Text("System").tag(AgentforceThemeMode.system)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Choose how the Agentforce UI appears in your app")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
            } header: {
                Text("Theme")
            } footer: {
                Text("Restart the app to apply theme changes")
                    .font(.caption)
                    .foregroundColor(colors.warning)
            }
            
            // Service Configuration Section
            Section {
                TextField("Service API URL", text: $settings.serviceAPI)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                TextField("Organization ID", text: $settings.organizationId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                TextField("Developer Name", text: $settings.developerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } header: {
                Text("Service Configuration")
            } footer: {
                Text("Configure the Service Agent deployment settings for your organization. All fields are required. Restart application to apply.")
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    showingResetConfirmation = true
                }
                .foregroundColor(.red)
            }
        }
        .confirmationDialog("Reset All Settings", isPresented: $showingResetConfirmation) {
            Button("Reset to Defaults", role: .destructive) {
                settings.resetToDefaults()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset all settings including theme and Service configuration to their default values. You'll need to restart the app to apply changes.")
        }

    }
}
