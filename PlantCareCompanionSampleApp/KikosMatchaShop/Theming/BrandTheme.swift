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

/// Central definition of how the Agentforce chat UI is themed in this sample.
///
/// The SDK exposes two composable theming inputs, and this type owns both:
///  1. `themeManager(mode:)` drives the chat UI's light / dark appearance and is
///     handed to `AgentforceClient` at construction time.
///  2. `theming` layers brand color overrides on top of the SDK's default palette
///     and is applied to the deployment configuration via `setTheming(_:)`. Any
///     token left unspecified falls back to the SDK default, so an empty map means
///     "use the stock Agentforce look".
///
/// This is the single place to customize the in-chat colors — edit `lightColors` /
/// `darkColors` below to rebrand the conversation surface.
enum BrandTheme {

    /// Builds the theme manager that controls the SDK chat UI's light/dark appearance.
    static func themeManager(mode: AgentforceThemeMode) -> AgentforceThemeManager {
        AgentforceDefaultThemeManager(themeMode: mode)
    }

    /// Brand color overrides layered on top of the SDK default palette.
    static var theming: AgentforceTheming {
        .overrides(light: lightColors, dark: darkColors)
    }

    // MARK: - Brand Palette

    /// Kiko's Matcha Shop brand colors, matched to the storefront design system
    /// (`MatchaStyle`): a single dark forest green over warm-white foregrounds. There
    /// is no secondary hue — the palette is deliberately minimal and premium, so the
    /// same forest green fills every branded surface across light and dark mode.
    private static let forest = Color(red: 0.086, green: 0.196, blue: 0.125)
    private static let forestDeep = Color(red: 0.05, green: 0.13, blue: 0.09)
    private static let onBrand = Color(red: 0.960, green: 0.956, blue: 0.945)

    /// Brand color overrides shared by both appearances. Any token left unspecified
    /// falls back to the SDK default.
    private static var brandColors: [AgentforceColorToken: Color] {
        [
            // Primary accent + title bar
            .accent1: forest,
            .titleBarBackground: forest,
            .titleBarTextColor: onBrand,
            .titleBarIconTint: onBrand,

            // User message bubbles (forest green)
            .userMessageBubbleBackground: forest,
            .userMessageBubbleTextColor: onBrand,

            // Send button (forest green)
            .sendButtonEnabledBackground: forest,
            .sendButtonIconTint: onBrand,

            // Launcher (forest green)
            .launcherBackground: forest,
            .launcherIconTint: onBrand,
            .launcherTextColor: onBrand,

            // Agent avatar, primary response buttons, voice (forest green)
            .agentAvatarBackground: forest,
            .agentAvatarIconTint: onBrand,
            .chatResponseButtonPrimaryBackground: forest,
            .chatResponseButtonPrimaryTextColor: onBrand,
            .voiceButtonBackground: forest,
            .voiceButtonAccentColor: forestDeep,
        ]
    }

    /// Color token overrides for light mode.
    private static let lightColors: [AgentforceColorToken: Color] = brandColors

    /// Color token overrides for dark mode.
    private static let darkColors: [AgentforceColorToken: Color] = brandColors
}
