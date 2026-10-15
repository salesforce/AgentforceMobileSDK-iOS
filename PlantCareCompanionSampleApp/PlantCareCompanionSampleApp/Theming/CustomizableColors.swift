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
import Observation
import AgentforceSDK
import SharedUI

// MARK: - Custom Color Store

/// Observable storage for runtime color overrides, keyed by `ColorToken` raw value.
///
/// Kept in its own `@Observable` object so SwiftUI views that read palette colors
/// re-render when a token is customized.
@Observable
nonisolated final class CustomColorStore {
    var light: [String: Color]
    var dark: [String: Color]
    /// Currently selected theme preset name (nil if custom)
    var presetName: String?

    init(light: [String: Color] = [:], dark: [String: Color] = [:]) {
        self.light = light
        self.dark = dark
    }
}

// MARK: - Customizable Palettes

/// Cosmos light palette with runtime overrides for the customizable tokens.
/// Every other token (including the SDK's component tokens) derives from these.
nonisolated final class CustomizableLightColors: AgentforceCosmosLightColors {
    private let store: CustomColorStore
    private var customColors: [String: Color] { store.light }

    init(store: CustomColorStore) {
        self.store = store
        super.init()
    }

    override var surface1: Color { customColors[ColorToken.surface1.rawValue] ?? super.surface1 }
    override var surface2: Color { customColors[ColorToken.surface2.rawValue] ?? super.surface2 }
    override var surfaceContainer1: Color { customColors[ColorToken.surfaceContainer1.rawValue] ?? super.surfaceContainer1 }
    override var surfaceContainer2: Color { customColors[ColorToken.surfaceContainer2.rawValue] ?? super.surfaceContainer2 }
    override var surfaceContainer3: Color { customColors[ColorToken.surfaceContainer3.rawValue] ?? super.surfaceContainer3 }
    override var onSurface1: Color { customColors[ColorToken.onSurface1.rawValue] ?? super.onSurface1 }
    override var onSurface2: Color { customColors[ColorToken.onSurface2.rawValue] ?? super.onSurface2 }
    override var onSurface3: Color { customColors[ColorToken.onSurface3.rawValue] ?? super.onSurface3 }
    override var accent1: Color { customColors[ColorToken.accent1.rawValue] ?? super.accent1 }
    override var accent2: Color { customColors[ColorToken.accent2.rawValue] ?? super.accent2 }
    override var accent3: Color { customColors[ColorToken.accent3.rawValue] ?? super.accent3 }
    override var accentContainer1: Color { customColors[ColorToken.accentContainer1.rawValue] ?? super.accentContainer1 }
    override var onAccent1: Color { customColors[ColorToken.onAccent1.rawValue] ?? super.onAccent1 }
    override var error1: Color { customColors[ColorToken.error1.rawValue] ?? super.error1 }
    override var errorContainer1: Color { customColors[ColorToken.errorContainer1.rawValue] ?? super.errorContainer1 }
    override var onError1: Color { customColors[ColorToken.onError1.rawValue] ?? super.onError1 }
    override var border1: Color { customColors[ColorToken.border1.rawValue] ?? super.border1 }
    override var borderError1: Color { customColors[ColorToken.borderError1.rawValue] ?? super.borderError1 }
    override var disabledContainer1: Color { customColors[ColorToken.disabledContainer1.rawValue] ?? super.disabledContainer1 }
    override var onDisabled1: Color { customColors[ColorToken.onDisabled1.rawValue] ?? super.onDisabled1 }
    override var onDisabled2: Color { customColors[ColorToken.onDisabled2.rawValue] ?? super.onDisabled2 }
}

/// Cosmos dark palette with runtime overrides for the customizable tokens.
/// Every other token (including the SDK's component tokens) derives from these.
nonisolated final class CustomizableDarkColors: AgentforceCosmosDarkColors {
    private let store: CustomColorStore
    private var customColors: [String: Color] { store.dark }

    init(store: CustomColorStore) {
        self.store = store
        super.init()
    }

    override var surface1: Color { customColors[ColorToken.surface1.rawValue] ?? super.surface1 }
    override var surface2: Color { customColors[ColorToken.surface2.rawValue] ?? super.surface2 }
    override var surfaceContainer1: Color { customColors[ColorToken.surfaceContainer1.rawValue] ?? super.surfaceContainer1 }
    override var surfaceContainer2: Color { customColors[ColorToken.surfaceContainer2.rawValue] ?? super.surfaceContainer2 }
    override var surfaceContainer3: Color { customColors[ColorToken.surfaceContainer3.rawValue] ?? super.surfaceContainer3 }
    override var onSurface1: Color { customColors[ColorToken.onSurface1.rawValue] ?? super.onSurface1 }
    override var onSurface2: Color { customColors[ColorToken.onSurface2.rawValue] ?? super.onSurface2 }
    override var onSurface3: Color { customColors[ColorToken.onSurface3.rawValue] ?? super.onSurface3 }
    override var accent1: Color { customColors[ColorToken.accent1.rawValue] ?? super.accent1 }
    override var accent2: Color { customColors[ColorToken.accent2.rawValue] ?? super.accent2 }
    override var accent3: Color { customColors[ColorToken.accent3.rawValue] ?? super.accent3 }
    override var accentContainer1: Color { customColors[ColorToken.accentContainer1.rawValue] ?? super.accentContainer1 }
    override var onAccent1: Color { customColors[ColorToken.onAccent1.rawValue] ?? super.onAccent1 }
    override var error1: Color { customColors[ColorToken.error1.rawValue] ?? super.error1 }
    override var errorContainer1: Color { customColors[ColorToken.errorContainer1.rawValue] ?? super.errorContainer1 }
    override var onError1: Color { customColors[ColorToken.onError1.rawValue] ?? super.onError1 }
    override var border1: Color { customColors[ColorToken.border1.rawValue] ?? super.border1 }
    override var borderError1: Color { customColors[ColorToken.borderError1.rawValue] ?? super.borderError1 }
    override var disabledContainer1: Color { customColors[ColorToken.disabledContainer1.rawValue] ?? super.disabledContainer1 }
    override var onDisabled1: Color { customColors[ColorToken.onDisabled1.rawValue] ?? super.onDisabled1 }
    override var onDisabled2: Color { customColors[ColorToken.onDisabled2.rawValue] ?? super.onDisabled2 }
}

// MARK: - Default Colors

nonisolated extension ColorToken {
    /// The SDK's default (Cosmos) color for this token.
    func defaultColor(isLightMode: Bool) -> Color {
        isLightMode ? defaultColor(in: AgentforceCosmosLightColors()) : defaultColor(in: AgentforceCosmosDarkColors())
    }

    private func defaultColor(in colors: SharedUI.Colors) -> Color {
        switch self {
        case .surface1: return colors.surface1
        case .surface2: return colors.surface2
        case .surfaceContainer1: return colors.surfaceContainer1
        case .surfaceContainer2: return colors.surfaceContainer2
        case .surfaceContainer3: return colors.surfaceContainer3
        case .onSurface1: return colors.onSurface1
        case .onSurface2: return colors.onSurface2
        case .onSurface3: return colors.onSurface3
        case .accent1: return colors.accent1
        case .accent2: return colors.accent2
        case .accent3: return colors.accent3
        case .accentContainer1: return colors.accentContainer1
        case .onAccent1: return colors.onAccent1
        case .error1: return colors.error1
        case .errorContainer1: return colors.errorContainer1
        case .onError1: return colors.onError1
        case .border1: return colors.border1
        case .borderError1: return colors.borderError1
        case .disabledContainer1: return colors.disabledContainer1
        case .onDisabled1: return colors.onDisabled1
        case .onDisabled2: return colors.onDisabled2
        }
    }
}
