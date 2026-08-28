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

/// Design system for the Kiko's Matcha storefront: minimal, premium, and
/// Japanese-inspired — a warm white canvas, dark forest-green accents, and serif
/// typography. Colors are sampled from the approved mockup. This is a deliberately
/// light, fixed palette (no gradients, minimal rounding, no heavy shadows).
enum MatchaStyle {

    // MARK: - Color

    /// Page and card background — a warm, paper-like off-white.
    static let warmWhite  = Color(red: 0.972, green: 0.964, blue: 0.953)
    /// A slightly deeper warm white for subtle fills.
    static let warmDim    = Color(red: 0.945, green: 0.937, blue: 0.922)
    /// Dark forest green — buttons, badges, the active tab, and the Ask Kiko pill.
    static let forest     = Color(red: 0.086, green: 0.196, blue: 0.125)
    /// A deeper forest for pressed/active button states.
    static let forestPressed = Color(red: 0.055, green: 0.133, blue: 0.086)
    /// Near-black forest ink for headlines and product names.
    static let ink        = Color(red: 0.114, green: 0.141, blue: 0.118)
    /// Warm gray for subtitles and descriptions.
    static let muted      = Color(red: 0.451, green: 0.435, blue: 0.412)
    /// Hairline color for borders and dividers.
    static let hairline   = Color(red: 0.850, green: 0.840, blue: 0.812)
    /// Text/icon color on a forest-green fill.
    static let onForest   = Color(red: 0.960, green: 0.956, blue: 0.945)

    // MARK: - Typography (serif = New York on iOS)

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Letter spacing for the wordmark and the small uppercase labels.
    static let wordmarkTracking: CGFloat = 6
    static let labelTracking: CGFloat = 2.5

    // MARK: - Metrics

    static let cardCorner: CGFloat = 6
    static let controlCorner: CGFloat = 3
    static let screenPadding: CGFloat = 20
}
