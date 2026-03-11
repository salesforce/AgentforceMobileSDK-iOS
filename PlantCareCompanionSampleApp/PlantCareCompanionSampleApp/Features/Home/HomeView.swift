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

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showChatSheet: Bool = false
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.themeColors) private var themeColors
    
    // Access settings through viewModel's compositionRoot
    // Using @Bindable to ensure UI updates when settings change
    private var settings: PlantCareSettings? {
        viewModel.compositionRoot?.settings
    }
    
    // Computed property to reactively track Service configuration status
    private var isServiceConfigured: Bool {
        settings?.isServiceConfigured ?? false
    }
    
    // Determine the effective color scheme based on settings
    private var effectiveColorScheme: ColorScheme {
        guard let settings = settings else { return systemColorScheme }
        
        switch settings.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return systemColorScheme
        }
    }
    
    // Get theme colors for the current scheme
    private var colors: PlantCareTheme.Colors {
        PlantCareTheme.Colors(colorScheme: effectiveColorScheme)
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: PlantCareTheme.Spacing.xl) {
            Spacer()
            
            // Welcome Header
            VStack(spacing: PlantCareTheme.Spacing.md) {
                Text("🌱")
                    .font(.system(size: 80))
                
                Text("Plant Care Companion")
                    .font(PlantCareTheme.Typography.largeTitle)
                    .foregroundColor(colors.textPrimary)
                
                Text("Ask our AI expert for plant care advice")
                    .font(PlantCareTheme.Typography.body)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PlantCareTheme.Spacing.xl)
            }
            
            Spacer()
            
            // Service Configuration Status
            serviceStatusView
            
            // Ask Expert Button (for iOS < 26, where Launcher isn't available)
            if #unavailable(iOS 26.0) {
                Button(action: {
                    showChatSheet = true
                }) {
                    HStack(spacing: PlantCareTheme.Spacing.md) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 24))
                        
                        Text("Ask Expert")
                            .font(PlantCareTheme.Typography.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlantCareTheme.Spacing.lg)
                    .background(colors.brand)
                    .cornerRadius(PlantCareTheme.Spacing.md)
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.6 : 1.0)
                .padding(.horizontal, PlantCareTheme.Spacing.xl)
                .padding(.top, PlantCareTheme.Spacing.sm)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: colors.brand))
                }
            } else {
                Text("Use the launcher below to start a conversation")
                    .font(PlantCareTheme.Typography.caption)
                    .foregroundColor(colors.textSecondary)
                    .padding(.top, PlantCareTheme.Spacing.sm)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.surface1)
        .preferredColorScheme(preferredColorScheme)
        .withThemeColors(colors)
        .sheet(isPresented: $showChatSheet) {
            viewModel.agentforceClient.getChatView {
                showChatSheet = false
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    // Compute preferred color scheme for the view
    private var preferredColorScheme: ColorScheme? {
        guard let settings = settings else { return nil }
        
        switch settings.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil  // Let system decide
        }
    }
    
    // Service Agent Configuration Status View
    private var serviceStatusView: some View {
        VStack(spacing: PlantCareTheme.Spacing.sm) {
            HStack(spacing: PlantCareTheme.Spacing.sm) {
                Image(systemName: isServiceConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isServiceConfigured ? .green : .orange)
                
                Text("Service Configuration")
                    .font(PlantCareTheme.Typography.headline)
                    .foregroundColor(colors.textPrimary)
                
                Spacer()
                
                Text(isServiceConfigured ? "Ready" : "Not Set")
                    .font(PlantCareTheme.Typography.caption)
                    .foregroundColor(isServiceConfigured ? .green : .orange)
                    .padding(.horizontal, PlantCareTheme.Spacing.sm)
                    .padding(.vertical, PlantCareTheme.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: PlantCareTheme.Spacing.xs)
                            .fill(isServiceConfigured ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    )
            }
            
            if !isServiceConfigured {
                Text("Please configure Service settings in the Settings tab to enable Service Agent mode.")
                    .font(PlantCareTheme.Typography.caption)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(PlantCareTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PlantCareTheme.Spacing.md)
                .fill(colors.surface2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PlantCareTheme.Spacing.md)
                .stroke(isServiceConfigured ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, PlantCareTheme.Spacing.xl)
    }
}

#Preview {
    let compositionRoot = CompositionRoot()
    return HomeView(viewModel: compositionRoot.makeHomeViewModel())
}
