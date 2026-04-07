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

enum PresentationState {
    case none, chat, voice
}

struct ContentView: View {
    @ObservedObject var compositionRoot: CompositionRoot
    @State private var selectedTab = 0
    @State private var presentationState: PresentationState = .none
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
        .modifier(MicrophoneAccessoryModifier(
            colors: colors,
            onMicTapped: {
                _ = compositionRoot.agentforceClient.getChatView(onClose: {
                    withAnimation(.easeInOut(duration: 0.3)) { presentationState = .none }
                })
                _ = compositionRoot.agentforceClient.getVoiceView(onContainerClose: {
                    withAnimation(.easeInOut(duration: 0.3)) { presentationState = .chat }
                })
                withAnimation(.easeInOut(duration: 0.3)) { presentationState = .voice }
            }
        ))
        .sheet(
            isPresented: Binding(
                get: { presentationState != .none },
                set: { isPresented in
                    if !isPresented {
                        withAnimation(.easeInOut(duration: 0.3)) { presentationState = .none }
                    }
                }
            )
        ) {
            ZStack {
                if presentationState == .chat || presentationState == .voice {
                    if let chatView = compositionRoot.agentforceClient.currentChatView {
                        chatView
                            .disabled(presentationState == .voice)
                    }
                }
                if presentationState == .voice {
                    if let voiceView = compositionRoot.agentforceClient.currentVoiceView {
                        voiceView
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: presentationState)
        }
        .preferredColorScheme(preferredColorScheme)
        .withThemeColors(colors)
    }
    
    struct MicrophoneAccessoryModifier: ViewModifier {
        let colors: PlantCareTheme.Colors
        let onMicTapped: () -> Void

        func body(content: Content) -> some View {
            if #available(iOS 26.0, *) {
                content
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .tabViewBottomAccessory {
                        MicrophoneButtonView(colors: colors, onTap: onMicTapped)
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
    
}

// MARK: - Microphone Button View

struct MicrophoneButtonView: View {
    let colors: PlantCareTheme.Colors
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colors.brand)
                        .frame(width: 44, height: 44)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ask your Plant Advisor")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Tap to start a conversation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.up")
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

