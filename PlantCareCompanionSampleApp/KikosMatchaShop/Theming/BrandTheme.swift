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

    /// Kiko's Matcha Shop brand colors. Matcha green is the primary fill; purple is
    /// the secondary accent. Both fills pair with white foregrounds for legible
    /// contrast in light and dark mode, so the same values are reused across schemes.
    private static let matchaGreen = Color(red: 0.49, green: 0.66, blue: 0.35)
    private static let matchaGreenDeep = Color(red: 0.38, green: 0.55, blue: 0.26)
    private static let accentPurple = Color(red: 0.55, green: 0.40, blue: 0.78)
    private static let onBrand = Color.white

    /// Brand color overrides shared by both appearances. Any token left unspecified
    /// falls back to the SDK default.
    private static var brandColors: [AgentforceColorToken: Color] {
        [
            // Primary accent + title bar
            .accent1: matchaGreen,
            .titleBarBackground: matchaGreen,
            .titleBarTextColor: onBrand,
            .titleBarIconTint: onBrand,

            // User message bubbles (matcha green)
            .userMessageBubbleBackground: matchaGreen,
            .userMessageBubbleTextColor: onBrand,

            // Send button (matcha green)
            .sendButtonEnabledBackground: matchaGreen,
            .sendButtonIconTint: onBrand,

            // Launcher (matcha green)
            .launcherBackground: matchaGreen,
            .launcherIconTint: onBrand,
            .launcherTextColor: onBrand,

            // Secondary accent (purple): agent avatar, primary response buttons, voice
            .agentAvatarBackground: accentPurple,
            .agentAvatarIconTint: onBrand,
            .chatResponseButtonPrimaryBackground: accentPurple,
            .chatResponseButtonPrimaryTextColor: onBrand,
            .voiceButtonBackground: accentPurple,
            .voiceButtonAccentColor: matchaGreenDeep,
        ]
    }

    /// Color token overrides for light mode.
    private static let lightColors: [AgentforceColorToken: Color] = brandColors

    /// Color token overrides for dark mode.
    private static let darkColors: [AgentforceColorToken: Color] = brandColors
}
