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

struct ContentView: View {
    @ObservedObject var compositionRoot: CompositionRoot
    @State private var launcher: AgentforceLauncher?
    @State private var selectedTab = 0
    @State private var showingLauncherChat = false
    @Environment(\.colorScheme) private var systemColorScheme
    
    // Determine the effective color scheme based on settings
    private var effectiveColorScheme: ColorScheme {
        switch compositionRoot.settings.themeMode {
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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView(viewModel: compositionRoot.makeHomeViewModel())
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Settings Tab
            NavigationView {
                SettingsView(settings: compositionRoot.settings)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(1)
        }
        .accentColor(colors.brand)
        .modifier(LauncherViewModifier(launcherView: self.launcher))
        .sheet(isPresented: $showingLauncherChat) {
            if let chatView = compositionRoot.agentforceClient.currentChatView {
                chatView
            } else {
                Text("Chat View Not Available")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            // Only build launcher if we're on 26
            if #available(iOS 26.0, *) {
                self.launcher = compositionRoot.agentforceClient.createLauncher(
                    launchChatView: { showingLauncherChat = true },
                    onClose: { showingLauncherChat = false }
                )
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .withThemeColors(colors)
    }
    
    struct LauncherViewModifier: ViewModifier {
        var launcherView: AgentforceLauncher?
        
        func body(content: Content) -> some View {
            // Only add the launcher accessory if we are iOS26
            if #available(iOS 26.0, *) {
                content
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .tabViewBottomAccessory {
                        launcherView
                    }
            } else {
                content
            }
        }
    }
    
    // Compute preferred color scheme for the view
    private var preferredColorScheme: ColorScheme? {
        switch compositionRoot.settings.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil  // Let system decide
        }
    }
    
    @available(iOS 26.0, *)
    private var launcherView: some View {
        Group {
            // If we aren't configured, show stub leading user to Settings
            if !compositionRoot.settings.isServiceConfigured {
                ConfigurationPromptView(selectedTab: $selectedTab, colors: colors)
            } else {
                launcher
            }
        }
    }
}

// MARK: - Configuration Prompt View

/// Stub view shown when Service is not configured, prompts user to go to Settings
struct ConfigurationPromptView: View {
    @Binding var selectedTab: Int
    let colors: PlantCareTheme.Colors
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Navigate to Settings tab
            withAnimation {
                selectedTab = 1
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "gear.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(colors.brand)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Configure Agent")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Set up Service in Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(colors.surface2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
