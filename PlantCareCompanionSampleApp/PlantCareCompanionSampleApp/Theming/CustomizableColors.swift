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

// MARK: - Customizable Colors Implementation

/// Colors implementation that uses custom colors when available, falling back to defaults
class CustomizableColors: AgentforceTheme.Colors {
    private let customColors: [String: Color]
    private let defaultColors: AgentforceTheme.Colors
    private let colorScheme: ColorScheme
    
    init(customColors: [String: Color], defaultColors: AgentforceTheme.Colors, colorScheme: ColorScheme) {
        self.customColors = customColors
        self.defaultColors = defaultColors
        self.colorScheme = colorScheme
    }
    
    private func color(for token: ColorToken) -> Color {
        customColors[token.rawValue] ?? getDefaultColor(for: token)
    }
    
    private func getDefaultColor(for token: ColorToken) -> Color {
        switch token {
        // Core surface colors
        case .surface1: return defaultColors.surface1
        case .surface2: return defaultColors.surface2
        case .surfaceContainer1: return defaultColors.surfaceContainer1
        case .surfaceContainer2: return defaultColors.surfaceContainer2
        case .surfaceContainer3: return defaultColors.surfaceContainer3
        // Essential text colors
        case .onSurface1: return defaultColors.onSurface1
        case .onSurface2: return defaultColors.onSurface2
        case .onSurface3: return defaultColors.onSurface3
        // Interactive colors
        case .accent1: return defaultColors.accent1
        case .accent2: return defaultColors.accent2
        case .accent3: return defaultColors.accent3
        case .accent4: return defaultColors.accent4
        case .accent5: return defaultColors.accent5
        case .accentContainer1: return defaultColors.accentContainer1
        case .onAccent1: return defaultColors.onAccent1
        // Feedback colors
        case .error1: return defaultColors.error1
        case .errorContainer1: return defaultColors.errorContainer1
        case .onError1: return defaultColors.onError1
        // Border colors
        case .border1: return defaultColors.border1
        case .borderError1: return defaultColors.borderError1
        // Disabled state colors
        case .disabledContainer1: return defaultColors.disabledContainer1
        case .onDisabled1: return defaultColors.onDisabled1
        case .onDisabled2: return defaultColors.onDisabled2
        }
    }
    
    // MARK: - Colors Protocol Implementation
    
    // Customizable colors (tokens we actually support customization for)
    var surface1: Color { color(for: .surface1) }
    var surface2: Color { color(for: .surface2) }
    var onSurface1: Color { color(for: .onSurface1) }
    var onSurface2: Color { color(for: .onSurface2) }
    var onSurface3: Color { color(for: .onSurface3) }
    var surfaceContainer1: Color { color(for: .surfaceContainer1) }
    var surfaceContainer2: Color { color(for: .surfaceContainer2) }
    var surfaceContainer3: Color { color(for: .surfaceContainer3) }
    var accent1: Color { color(for: .accent1) }
    var accent2: Color { color(for: .accent2) }
    var accent3: Color { color(for: .accent3) }
    var accent4: Color { color(for: .accent4) }
    var accent5: Color { color(for: .accent5) }
    var accent6: Color { color(for: .accent5) }
    var accent7: Color { color(for: .accent5) }
    var accent8: Color { color(for: .accent5) }
    var accentContainer1: Color { color(for: .accentContainer1) }
    var onAccent1: Color { color(for: .onAccent1) }
    var error1: Color { color(for: .error1) }
    var errorContainer1: Color { color(for: .errorContainer1) }
    var onError1: Color { color(for: .onError1) }
    var border1: Color { color(for: .border1) }
    var borderError1: Color { color(for: .borderError1) }
    var disabledContainer1: Color { color(for: .disabledContainer1) }
    var onDisabled1: Color { color(for: .onDisabled1) }
    var onDisabled2: Color { color(for: .onDisabled2) }
    
    // Non-customizable colors (use defaults directly)
    var border2: Color { defaultColors.border2 }
    var borderInverse2: Color { defaultColors.borderInverse2 }
    var borderDisabled1: Color { defaultColors.borderDisabled1 }
    var borderAgentforce1: Color { defaultColors.borderAgentforce1 }
    var borderSuccess1: Color { defaultColors.borderSuccess1 }
    var successContainer1: Color { defaultColors.successContainer1 }
    var onSuccess1: Color { defaultColors.onSuccess1 }
    var disabledContainer2: Color { defaultColors.disabledContainer2 }
    var brandBase50: Color { defaultColors.brandBase50 }
    var errorBase50: Color { defaultColors.errorBase50 }
    var feedbackWarning1: Color { defaultColors.feedbackWarning1 }
    var feedbackWarningContainer1: Color { defaultColors.feedbackWarningContainer1 }
    var info1: Color { defaultColors.info1 }
    var infoContainer1: Color { defaultColors.infoContainer1 }
    var foregroundColor: Color { defaultColors.foregroundColor }
    var backgroundColor: Color { defaultColors.backgroundColor }
}

