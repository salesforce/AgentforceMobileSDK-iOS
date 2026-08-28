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

    private let columns = [
        GridItem(.flexible(), spacing: KikoTheme.Spacing.md),
        GridItem(.flexible(), spacing: KikoTheme.Spacing.md),
    ]

    // Access settings through viewModel's compositionRoot
    // Using @Bindable to ensure UI updates when settings change
    private var settings: KikoSettings? {
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
    private var colors: KikoTheme.Colors {
        KikoTheme.Colors(colorScheme: effectiveColorScheme)
    }

    init(viewModel: HomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: KikoTheme.Spacing.xl) {
                shopHeader

                chatCallToAction

                menuSection(for: .drinks)
                menuSection(for: .sweets)

                serviceStatusView

                footer
            }
            .padding(.horizontal, KikoTheme.Spacing.lg)
            .padding(.top, KikoTheme.Spacing.xl)
            .padding(.bottom, KikoTheme.Spacing.xxl)
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

    // MARK: - Header

    private var shopHeader: some View {
        VStack(spacing: KikoTheme.Spacing.sm) {
            Text("🍵")
                .font(.system(size: 64))

            Text("Kiko's Matcha Shop")
                .font(KikoTheme.Typography.largeTitle)
                .foregroundColor(colors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: KikoTheme.Spacing.xs) {
                Text("🐕")
                Text("“Hi, I'm Kiko! Ask me anything about our menu.”")
                    .font(KikoTheme.Typography.body)
                    .foregroundColor(colors.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chat entry point

    @ViewBuilder
    private var chatCallToAction: some View {
        // On iOS 26+ the persistent launcher lives in the tab bar, so we only
        // surface an in-page button on earlier versions.
        if #unavailable(iOS 26.0) {
            Button(action: { showChatSheet = true }) {
                HStack(spacing: KikoTheme.Spacing.sm) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20))
                    Text("Ask Kiko")
                        .font(KikoTheme.Typography.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, KikoTheme.Spacing.md)
                .background(colors.brand)
                .cornerRadius(KikoTheme.CornerRadius.lg)
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1.0)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: colors.brand))
            }
        } else {
            Label("Tap the Kiko launcher below to start a chat", systemImage: "arrow.down.circle")
                .font(KikoTheme.Typography.caption)
                .foregroundColor(colors.textSecondary)
        }
    }

    // MARK: - Menu

    private func menuSection(for category: MenuItem.Category) -> some View {
        VStack(alignment: .leading, spacing: KikoTheme.Spacing.md) {
            Text(category.rawValue)
                .font(KikoTheme.Typography.title)
                .foregroundColor(colors.textPrimary)

            LazyVGrid(columns: columns, spacing: KikoTheme.Spacing.md) {
                ForEach(MenuItem.items(in: category)) { item in
                    MenuItemCard(item: item, colors: colors)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Service status (compact footer chip)

    private var serviceStatusView: some View {
        VStack(spacing: KikoTheme.Spacing.sm) {
            HStack(spacing: KikoTheme.Spacing.sm) {
                Image(systemName: isServiceConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isServiceConfigured ? colors.brand : .orange)

                Text("Agent Configuration")
                    .font(KikoTheme.Typography.headline)
                    .foregroundColor(colors.textPrimary)

                Spacer()

                Text(isServiceConfigured ? "Ready" : "Not Set")
                    .font(KikoTheme.Typography.caption)
                    .foregroundColor(isServiceConfigured ? colors.brand : .orange)
                    .padding(.horizontal, KikoTheme.Spacing.sm)
                    .padding(.vertical, KikoTheme.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.sm)
                            .fill((isServiceConfigured ? colors.brand : Color.orange).opacity(0.12))
                    )
            }

            if !isServiceConfigured {
                Text("Configure the Service Agent in the Settings tab to chat with Kiko.")
                    .font(KikoTheme.Typography.caption)
                    .foregroundColor(colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(KikoTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.md)
                .fill(colors.surface2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.md)
                .stroke((isServiceConfigured ? colors.brand : Color.orange).opacity(0.3), lineWidth: 1)
        )
    }

    private var footer: some View {
        Text("Freshly whisked daily · Powered by Agentforce")
            .font(KikoTheme.Typography.caption)
            .foregroundColor(colors.textDisabled)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
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
}

// MARK: - Menu Item Card

struct MenuItemCard: View {
    let item: MenuItem
    let colors: KikoTheme.Colors

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: KikoTheme.Spacing.xs) {
                Text(item.name)
                    .font(KikoTheme.Typography.headline)
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(item.tagline)
                    .font(KikoTheme.Typography.caption)
                    .foregroundColor(colors.textSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .topLeading)

                Text(item.price)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colors.brand)
            }
            .padding(.horizontal, KikoTheme.Spacing.md)
            .padding(.bottom, KikoTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.lg)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.lg)
                .stroke(colors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.lg))
        .shadow(color: colors.cardShadow, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let compositionRoot = CompositionRoot()
    return HomeView(viewModel: compositionRoot.makeHomeViewModel())
}
