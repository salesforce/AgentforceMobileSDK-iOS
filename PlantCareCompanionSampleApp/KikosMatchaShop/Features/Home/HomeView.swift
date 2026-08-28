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

/// Kiko's Matcha storefront home screen — a warm, minimal, Japanese-inspired layout:
/// wordmark header, full-bleed hero, and a two-column featured-product grid.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    /// Opens the hamburger destination (Settings).
    let onMenu: () -> Void
    /// Navigates to the Shop tab (used by "Explore matcha" / "View all").
    let onShop: () -> Void

    private var isServiceConfigured: Bool {
        viewModel.compositionRoot?.settings.isServiceConfigured ?? false
    }

    init(viewModel: HomeViewModel, onMenu: @escaping () -> Void, onShop: @escaping () -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onMenu = onMenu
        self.onShop = onShop
    }

    var body: some View {
        VStack(spacing: 0) {
            StoreHeader(onMenu: onMenu)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    HeroBanner(onExplore: onShop)

                    VStack(spacing: 18) {
                        sectionHeader
                        productGrid
                        if !isServiceConfigured {
                            configureNotice
                        }
                    }
                    .padding(.horizontal, MatchaStyle.screenPadding)
                }
                .padding(.bottom, 150) // clear the bottom nav + floating Ask Kiko button
            }
        }
        .background(MatchaStyle.warmWhite.ignoresSafeArea())
    }

    // MARK: - Featured section

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("FEATURED MATCHA")
                .font(MatchaStyle.serif(15, .medium))
                .tracking(MatchaStyle.labelTracking)
                .foregroundColor(MatchaStyle.ink)

            Spacer()

            Button(action: onShop) {
                HStack(spacing: 6) {
                    Text("View all")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .regular))
                }
                .font(MatchaStyle.serif(14))
                .foregroundColor(MatchaStyle.muted)
            }
        }
    }

    private var productGrid: some View {
        HStack(alignment: .top, spacing: 14) {
            ForEach(Product.featured) { product in
                ProductCard(product: product)
            }
        }
    }

    private var configureNotice: some View {
        Button(action: onMenu) {
            HStack(spacing: 10) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                Text("Configure the agent in Settings to chat with Kiko.")
                    .font(MatchaStyle.serif(13))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(MatchaStyle.muted)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(MatchaStyle.warmDim)
            .overlay(
                RoundedRectangle(cornerRadius: MatchaStyle.cardCorner)
                    .stroke(MatchaStyle.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: MatchaStyle.cardCorner))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Store Header (shared chrome)

/// The top bar: hamburger (menu), the centered KIKO'S / MATCHA wordmark, and the
/// search + bag icons.
struct StoreHeader: View {
    let onMenu: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text("KIKO'S")
                    .font(MatchaStyle.serif(26, .medium))
                    .tracking(MatchaStyle.wordmarkTracking)
                Text("MATCHA")
                    .font(MatchaStyle.serif(12))
                    .tracking(MatchaStyle.wordmarkTracking)
            }
            .foregroundColor(MatchaStyle.ink)

            HStack {
                Button(action: onMenu) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .regular))
                }
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                    Image(systemName: "bag")
                }
                .font(.system(size: 19, weight: .regular))
            }
            .foregroundColor(MatchaStyle.ink)
        }
        .padding(.horizontal, MatchaStyle.screenPadding)
        .padding(.vertical, 12)
        .background(MatchaStyle.warmWhite)
        .overlay(alignment: .bottom) {
            Rectangle().fill(MatchaStyle.hairline).frame(height: 1)
        }
    }
}

// MARK: - Hero

private struct HeroBanner: View {
    let onExplore: () -> Void

    var body: some View {
        // Color.clear takes the proposed (full) width so the photo's own intrinsic
        // size can't dictate layout; the overlaid image fills and crops to fit.
        Color.clear
            .overlay(
                Image("hero_matcha")
                    .resizable()
                    .scaledToFill()
            )
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Japanese tea,\nthoughtfully\nselected.")
                        .font(MatchaStyle.serif(34, .medium))
                        .foregroundColor(MatchaStyle.onForest)
                        .lineSpacing(2)

                    Text("Premium Japanese matcha,\nthoughtfully sourced.")
                        .font(MatchaStyle.serif(15))
                        .foregroundColor(MatchaStyle.onForest.opacity(0.92))

                    Button(action: onExplore) {
                        HStack(spacing: 12) {
                            Text("EXPLORE MATCHA")
                                .tracking(MatchaStyle.labelTracking)
                            Image(systemName: "arrow.right")
                        }
                        .font(MatchaStyle.serif(13, .medium))
                        .foregroundColor(MatchaStyle.onForest)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(MatchaStyle.forest)
                        .clipShape(RoundedRectangle(cornerRadius: MatchaStyle.controlCorner))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, MatchaStyle.screenPadding)
                .padding(.bottom, 26)
                .shadow(color: .black.opacity(0.45), radius: 8, x: 0, y: 2)
            }
    }
}

// MARK: - Product Card

/// A single featured-product card: photo with a grade badge, product name, tasting
/// note, a hairline divider, and a leaf-marked use description. Minimal rounding,
/// hairline border, no heavy shadow.
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .overlay(
                    Image(product.imageName)
                        .resizable()
                        .scaledToFill()
                )
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .topLeading) {
                    Text(product.badge)
                        .font(MatchaStyle.serif(11, .medium))
                        .tracking(MatchaStyle.labelTracking)
                        .foregroundColor(MatchaStyle.onForest)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MatchaStyle.forest)
                        .clipShape(RoundedRectangle(cornerRadius: MatchaStyle.controlCorner))
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(MatchaStyle.serif(19, .medium))
                    .foregroundColor(MatchaStyle.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(product.tasting)
                    .font(MatchaStyle.serif(14))
                    .foregroundColor(MatchaStyle.muted)

                Rectangle()
                    .fill(MatchaStyle.hairline)
                    .frame(height: 1)
                    .padding(.vertical, 8)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "leaf")
                        .font(.system(size: 13))
                        .foregroundColor(MatchaStyle.forest)
                    Text(product.note)
                        .font(MatchaStyle.serif(13))
                        .foregroundColor(MatchaStyle.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(MatchaStyle.warmWhite)
        .overlay(
            RoundedRectangle(cornerRadius: MatchaStyle.cardCorner)
                .stroke(MatchaStyle.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MatchaStyle.cardCorner))
    }
}

#Preview {
    let compositionRoot = CompositionRoot()
    return HomeView(viewModel: compositionRoot.makeHomeViewModel(), onMenu: {}, onShop: {})
}
