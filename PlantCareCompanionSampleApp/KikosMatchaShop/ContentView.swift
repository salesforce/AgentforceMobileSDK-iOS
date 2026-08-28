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

/// The storefront's four destinations, shown in the custom bottom navigation.
enum StoreTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case shop = "Shop"
    case learn = "Learn"
    case orders = "Orders"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home:   return "house"
        case .shop:   return "bag"
        case .learn:  return "book"
        case .orders: return "shippingbox"
        }
    }
}

/// Root of the Kiko's Matcha storefront. A custom light-mode scaffold — no system
/// TabView chrome — with a warm-white canvas, a bottom nav (Home · Shop · Learn ·
/// Orders), and a floating "Ask Kiko" launcher pill that opens the Agentforce
/// chat. Settings live behind the header's menu button.
struct ContentView: View {
    @ObservedObject var compositionRoot: CompositionRoot
    @State private var selectedTab: StoreTab = .home
    @State private var showingChat = false
    @State private var showingSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            MatchaStyle.warmWhite.ignoresSafeArea()

            currentScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    AskKikoButton { showingChat = true }
                        .padding(.trailing, MatchaStyle.screenPadding)
                        .padding(.bottom, 92)
                }

            BottomNavBar(selection: $selectedTab)
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(settings: compositionRoot.settings)
            }
        }
        .sheet(isPresented: $showingChat) {
            chatSheet
        }
    }

    // MARK: - Screens

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .home:
            HomeView(
                viewModel: compositionRoot.makeHomeViewModel(),
                onMenu: { showingSettings = true },
                onShop: { selectedTab = .shop }
            )
        case .shop:
            PlaceholderScreen(
                tab: .shop,
                headline: "The shop is steeping.",
                message: "Our full matcha selection is being packed with care. Ceremonial and Culinary are featured on the home screen."
            )
        case .learn:
            PlaceholderScreen(
                tab: .learn,
                headline: "The art of matcha.",
                message: "Brewing guides, sourcing stories, and the ritual of tea — thoughtfully written, arriving soon."
            )
        case .orders:
            PlaceholderScreen(
                tab: .orders,
                headline: "No orders yet.",
                message: "When you place an order, you'll be able to follow it here from our garden to your cup."
            )
        }
    }

    // MARK: - Chat sheet

    @ViewBuilder
    private var chatSheet: some View {
        if let chatView = compositionRoot.agentforceClient.getChatView(onClose: { showingChat = false }) {
            chatView
        } else {
            UnconfiguredChatView(
                onOpenSettings: {
                    showingChat = false
                    showingSettings = true
                }
            )
        }
    }
}

// MARK: - Bottom Navigation

private struct BottomNavBar: View {
    @Binding var selection: StoreTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(StoreTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .regular))
                        Text(tab.rawValue)
                            .font(MatchaStyle.serif(11))
                    }
                    .foregroundColor(selection == tab ? MatchaStyle.forest : MatchaStyle.muted)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(
            MatchaStyle.warmWhite
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .top) {
                    Rectangle().fill(MatchaStyle.hairline).frame(height: 1)
                }
        )
    }
}

// MARK: - Ask Kiko (floating voice launcher)

/// The floating "Ask Kiko" launcher pill. Matches the storefront mockup: a forest
/// capsule holding a circular brand mark, the serif "Ask Kiko" label, a hairline
/// divider, and a microphone icon. Tapping it opens the Ask Kiko conversation.
private struct AskKikoButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                // Circular brand mark — the app icon (Kiko mascot), matching the
                // mockup's avatar. Referenced via a dedicated imageset because app
                // icon sets can't be loaded by name in SwiftUI.
                Image("kiko_mark")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(MatchaStyle.onForest.opacity(0.5), lineWidth: 1))

                Text("Ask Kiko")
                    .font(MatchaStyle.serif(17, .medium))

                Rectangle()
                    .fill(MatchaStyle.onForest.opacity(0.3))
                    .frame(width: 1, height: 22)

                Image(systemName: "mic.fill")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(MatchaStyle.onForest)
        }
        .buttonStyle(AskKikoPillStyle())
        .accessibilityLabel("Ask Kiko")
    }
}

/// Button style for the Ask Kiko pill: a solid forest capsule that darkens to a
/// deeper forest on press, instead of the default style's fade to transparent.
private struct AskKikoPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.leading, 8)
            .padding(.trailing, 18)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(configuration.isPressed ? MatchaStyle.forestPressed : MatchaStyle.forest)
            )
            .overlay(
                Capsule().stroke(MatchaStyle.onForest.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Placeholder screens (Shop / Learn / Orders)

/// A clean "coming soon" screen for the not-yet-built destinations, sharing the
/// storefront header and palette so navigation feels complete.
private struct PlaceholderScreen: View {
    let tab: StoreTab
    let headline: String
    let message: String

    var body: some View {
        VStack(spacing: 0) {
            StoreHeader(onMenu: {})

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: tab.icon)
                    .font(.system(size: 40, weight: .regular))
                    .foregroundColor(MatchaStyle.forest)

                Text(headline)
                    .font(MatchaStyle.serif(26, .medium))
                    .foregroundColor(MatchaStyle.ink)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(MatchaStyle.serif(15))
                    .foregroundColor(MatchaStyle.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 36)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MatchaStyle.warmWhite)
    }
}

// MARK: - Unconfigured chat fallback

/// Shown when the Ask Kiko button is tapped before the Service Agent is configured.
private struct UnconfiguredChatView: View {
    let onOpenSettings: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 40))
                .foregroundColor(MatchaStyle.forest)

            Text("Ask Kiko")
                .font(MatchaStyle.serif(26, .medium))
                .foregroundColor(MatchaStyle.ink)

            Text("Add your Service Agent details in Settings to start chatting with Kiko about matcha, brewing, and orders.")
                .font(MatchaStyle.serif(15))
                .foregroundColor(MatchaStyle.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 32)

            Button(action: onOpenSettings) {
                Text("OPEN SETTINGS")
                    .tracking(MatchaStyle.labelTracking)
                    .font(MatchaStyle.serif(14, .medium))
                    .foregroundColor(MatchaStyle.onForest)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 14)
                    .background(MatchaStyle.forest)
                    .clipShape(RoundedRectangle(cornerRadius: MatchaStyle.controlCorner))
            }
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MatchaStyle.warmWhite.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(MatchaStyle.muted)
                    .padding(20)
            }
        }
    }
}
