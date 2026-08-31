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

// MARK: - Theme Preset Structure

struct ThemePreset: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let organization: String
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let lightColors: [String: Color]
    let darkColors: [String: Color]
    let previewColors: [Color]
    
    init(name: String, description: String, organization: String, primaryColor: Color, secondaryColor: Color, accentColor: Color, lightColors: [String: Color] = [:], darkColors: [String: Color] = [:], previewColors: [Color] = []) {
        self.name = name
        self.description = description
        self.organization = organization
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.lightColors = lightColors
        self.darkColors = darkColors
        self.previewColors = previewColors.isEmpty ? [primaryColor, secondaryColor, accentColor] : previewColors
    }
}

// MARK: - Predefined Theme Presets

extension ThemePreset {
    
    // MARK: - Default Theme
    
    static let defaultSalesforce = ThemePreset(
        name: "Default",
        description: "Original Salesforce Agentforce theme",
        organization: "Salesforce",
        primaryColor: Color(hex: "#0176D3") ?? .blue,
        secondaryColor: Color(hex: "#F3F3F3") ?? .gray,
        accentColor: Color(hex: "#032D60") ?? .blue,
        lightColors: [
            "surface1": Color(hex: "#FFFFFF") ?? .white,
            "surface2": Color(hex: "#F3F3F3") ?? .gray,
            "surfaceContainer1": Color(hex: "#F3F3F3") ?? .gray,
            "surfaceContainer3": Color(hex: "#D8D8D8") ?? .gray,
            "onSurface1": Color(hex: "#000000") ?? .black,
            "onSurface2": Color(hex: "#222222") ?? .gray,
            "onSurface3": Color(hex: "#939393") ?? .gray,
            "accent1": Color(hex: "#0176D3") ?? .blue,
            "accent2": Color(hex: "#F2F2F2") ?? .gray,
            "accent3": Color(hex: "#D6E6FF") ?? .blue,
            "accent4": Color(hex: "#05628A") ?? .blue,
            "accent5": Color(hex: "#EAF5FE") ?? .blue,
            "accentContainer1": Color(hex: "#E9F5FF") ?? .blue,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#BA0517") ?? .red,
            "errorContainer1": Color(hex: "#FCE8E6") ?? .red
        ],
        darkColors: [
            "surface1": Color(hex: "#1F1F1F") ?? .black,
            "surface2": Color(hex: "#302D2D") ?? .gray,
            "surfaceContainer1": Color(hex: "#2E2E2E") ?? .gray,
            "surfaceContainer3": Color(hex: "#BEBEBE") ?? .gray,
            "onSurface1": Color(hex: "#FFFFFF") ?? .white,
            "onSurface2": Color(hex: "#D5D5D5") ?? .gray,
            "onSurface3": Color(hex: "#898989") ?? .gray,
            "accent1": Color(hex: "#4BA3EA") ?? .blue,
            "accent2": Color(hex: "#777777") ?? .gray,
            "accent3": Color(hex: "#1F1F1F") ?? .black,
            "accent4": Color(hex: "#7BC8F3") ?? .blue,
            "accent5": Color(hex: "#16374C") ?? .blue,
            "accentContainer1": Color(hex: "#001A30") ?? .blue,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#FF5449") ?? .red,
            "errorContainer1": Color(hex: "#1F0000") ?? .red
        ],
        previewColors: [
            Color(hex: "#0176D3") ?? .blue,
            Color(hex: "#032D60") ?? .blue,
            Color(hex: "#5AA2E8") ?? .blue,
            Color(hex: "#F6FAFF") ?? .white
        ]
    )
    
    // MARK: - Nature Themes
    
    static let forest = ThemePreset(
        name: "Forest",
        description: "Deep forest greens with earth tones and natural wood accents",
        organization: "Nature",
        primaryColor: Color(hex: "#2D5016") ?? .green,
        secondaryColor: Color(hex: "#8B4513") ?? .brown,
        accentColor: Color(hex: "#228B22") ?? .green,
        lightColors: [
            "surface1": Color(hex: "#F5F5DC") ?? .gray,
            "surface2": Color(hex: "#F0F8E8") ?? .green,
            "surfaceContainer1": Color(hex: "#E8F5E8") ?? .green,
            "surfaceContainer3": Color(hex: "#D0E8D0") ?? .green,
            "onSurface1": Color(hex: "#2D5016") ?? .green,
            "onSurface2": Color(hex: "#1A3E0A") ?? .green,
            "onSurface3": Color(hex: "#4C6B3C") ?? .green,
            "accent1": Color(hex: "#228B22") ?? .green,
            "accent2": Color(hex: "#32CD32") ?? .green,
            "accent3": Color(hex: "#E8F5E8") ?? .green,
            "accent4": Color(hex: "#1B6F1B") ?? .green,
            "accent5": Color(hex: "#F0F8E8") ?? .white,
            "accentContainer1": Color(hex: "#E8F5E8") ?? .green,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#D32F2F") ?? .red,
            "errorContainer1": Color(hex: "#FFEBEE") ?? .red
        ],
        darkColors: [
            "surface1": Color(hex: "#1A3E0A") ?? .green,
            "surface2": Color(hex: "#2D5016") ?? .green,
            "surfaceContainer1": Color(hex: "#0D4218") ?? .black,
            "surfaceContainer3": Color(hex: "#3A5F2A") ?? .green,
            "onSurface1": Color(hex: "#F0F8E8") ?? .white,
            "onSurface2": Color(hex: "#E8F5E8") ?? .green,
            "onSurface3": Color(hex: "#A8D5A8") ?? .green,
            "accent1": Color(hex: "#32CD32") ?? .green,
            "accent2": Color(hex: "#90EE90") ?? .green,
            "accent3": Color(hex: "#0D4218") ?? .black,
            "accent4": Color(hex: "#3FCD3F") ?? .green,
            "accent5": Color(hex: "#0A2F14") ?? .black,
            "accentContainer1": Color(hex: "#0D4218") ?? .black,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#FF5252") ?? .red,
            "errorContainer1": Color(hex: "#5D1A1A") ?? .red
        ],
        previewColors: [
            Color(hex: "#2D5016") ?? .green,
            Color(hex: "#228B22") ?? .green,
            Color(hex: "#8B4513") ?? .brown,
            Color(hex: "#90EE90") ?? .green
        ]
    )
    
    static let botanical = ThemePreset(
        name: "Botanical Garden",
        description: "Fresh leafy greens with botanical sophistication",
        organization: "Nature",
        primaryColor: Color(hex: "#4CAF50") ?? .green,
        secondaryColor: Color(hex: "#81C784") ?? .green,
        accentColor: Color(hex: "#2E7D32") ?? .green,
        lightColors: [
            "surface1": Color(hex: "#FFFFFF") ?? .white,
            "surface2": Color(hex: "#F1F8E9") ?? .green,
            "surfaceContainer1": Color(hex: "#E8F5E9") ?? .green,
            "surfaceContainer3": Color(hex: "#C8E6C9") ?? .green,
            "onSurface1": Color(hex: "#1B5E20") ?? .green,
            "onSurface2": Color(hex: "#2E7D32") ?? .green,
            "onSurface3": Color(hex: "#66BB6A") ?? .green,
            "accent1": Color(hex: "#4CAF50") ?? .green,
            "accent2": Color(hex: "#81C784") ?? .green,
            "accent3": Color(hex: "#E8F5E9") ?? .green,
            "accent4": Color(hex: "#2E7D32") ?? .green,
            "accent5": Color(hex: "#F1F8E9") ?? .white,
            "accentContainer1": Color(hex: "#E8F5E9") ?? .green,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#D32F2F") ?? .red,
            "errorContainer1": Color(hex: "#FFEBEE") ?? .red
        ],
        darkColors: [
            "surface1": Color(hex: "#1B3A1B") ?? .green,
            "surface2": Color(hex: "#2E4E2E") ?? .green,
            "surfaceContainer1": Color(hex: "#1B5E20") ?? .green,
            "surfaceContainer3": Color(hex: "#33691E") ?? .green,
            "onSurface1": Color(hex: "#E8F5E9") ?? .white,
            "onSurface2": Color(hex: "#C8E6C9") ?? .green,
            "onSurface3": Color(hex: "#A5D6A7") ?? .green,
            "accent1": Color(hex: "#66BB6A") ?? .green,
            "accent2": Color(hex: "#81C784") ?? .green,
            "accent3": Color(hex: "#1B5E20") ?? .black,
            "accent4": Color(hex: "#4CAF50") ?? .green,
            "accent5": Color(hex: "#0F3314") ?? .black,
            "accentContainer1": Color(hex: "#1B5E20") ?? .black,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#FF5252") ?? .red,
            "errorContainer1": Color(hex: "#5D1A1A") ?? .red
        ],
        previewColors: [
            Color(hex: "#4CAF50") ?? .green,
            Color(hex: "#81C784") ?? .green,
            Color(hex: "#2E7D32") ?? .green,
            Color(hex: "#C8E6C9") ?? .green
        ]
    )
    
    static let tropicalRainforest = ThemePreset(
        name: "Tropical Rainforest",
        description: "Lush jungle greens with vibrant tropical accents",
        organization: "Nature",
        primaryColor: Color(hex: "#00695C") ?? .teal,
        secondaryColor: Color(hex: "#26A69A") ?? .teal,
        accentColor: Color(hex: "#FFB74D") ?? .orange,
        lightColors: [
            "surface1": Color(hex: "#FFFFFF") ?? .white,
            "surface2": Color(hex: "#E0F2F1") ?? .teal,
            "surfaceContainer1": Color(hex: "#B2DFDB") ?? .teal,
            "surfaceContainer3": Color(hex: "#80CBC4") ?? .teal,
            "onSurface1": Color(hex: "#004D40") ?? .teal,
            "onSurface2": Color(hex: "#00695C") ?? .teal,
            "onSurface3": Color(hex: "#00897B") ?? .teal,
            "accent1": Color(hex: "#00695C") ?? .teal,
            "accent2": Color(hex: "#26A69A") ?? .teal,
            "accent3": Color(hex: "#E0F2F1") ?? .teal,
            "accent4": Color(hex: "#FFB74D") ?? .orange,
            "accent5": Color(hex: "#FFF3E0") ?? .white,
            "accentContainer1": Color(hex: "#E0F2F1") ?? .teal,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#D32F2F") ?? .red,
            "errorContainer1": Color(hex: "#FFEBEE") ?? .red
        ],
        darkColors: [
            "surface1": Color(hex: "#00251A") ?? .teal,
            "surface2": Color(hex: "#003329") ?? .teal,
            "surfaceContainer1": Color(hex: "#004D40") ?? .teal,
            "surfaceContainer3": Color(hex: "#00695C") ?? .teal,
            "onSurface1": Color(hex: "#E0F2F1") ?? .white,
            "onSurface2": Color(hex: "#B2DFDB") ?? .teal,
            "onSurface3": Color(hex: "#80CBC4") ?? .teal,
            "accent1": Color(hex: "#26A69A") ?? .teal,
            "accent2": Color(hex: "#4DB6AC") ?? .teal,
            "accent3": Color(hex: "#003329") ?? .black,
            "accent4": Color(hex: "#FFB74D") ?? .orange,
            "accent5": Color(hex: "#663D00") ?? .black,
            "accentContainer1": Color(hex: "#003329") ?? .black,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#FF5252") ?? .red,
            "errorContainer1": Color(hex: "#5D1A1A") ?? .red
        ],
        previewColors: [
            Color(hex: "#00695C") ?? .teal,
            Color(hex: "#26A69A") ?? .teal,
            Color(hex: "#FFB74D") ?? .orange,
            Color(hex: "#80CBC4") ?? .teal
        ]
    )
    
    static let desert = ThemePreset(
        name: "Desert Bloom",
        description: "Warm desert tones with succulent-inspired colors",
        organization: "Nature",
        primaryColor: Color(hex: "#8D6E63") ?? .brown,
        secondaryColor: Color(hex: "#A1887F") ?? .brown,
        accentColor: Color(hex: "#FF8A65") ?? .orange,
        lightColors: [
            "surface1": Color(hex: "#FFF8E1") ?? .yellow,
            "surface2": Color(hex: "#FFECB3") ?? .yellow,
            "surfaceContainer1": Color(hex: "#FFE0B2") ?? .orange,
            "surfaceContainer3": Color(hex: "#FFCC80") ?? .orange,
            "onSurface1": Color(hex: "#3E2723") ?? .brown,
            "onSurface2": Color(hex: "#5D4037") ?? .brown,
            "onSurface3": Color(hex: "#8D6E63") ?? .brown,
            "accent1": Color(hex: "#FF8A65") ?? .orange,
            "accent2": Color(hex: "#FFAB91") ?? .orange,
            "accent3": Color(hex: "#FFE0B2") ?? .orange,
            "accent4": Color(hex: "#8D6E63") ?? .brown,
            "accent5": Color(hex: "#FFF8E1") ?? .white,
            "accentContainer1": Color(hex: "#FFE0B2") ?? .orange,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#D32F2F") ?? .red,
            "errorContainer1": Color(hex: "#FFEBEE") ?? .red
        ],
        darkColors: [
            "surface1": Color(hex: "#2E1E1A") ?? .brown,
            "surface2": Color(hex: "#3E2723") ?? .brown,
            "surfaceContainer1": Color(hex: "#4E342E") ?? .brown,
            "surfaceContainer3": Color(hex: "#5D4037") ?? .brown,
            "onSurface1": Color(hex: "#FFF8E1") ?? .white,
            "onSurface2": Color(hex: "#FFECB3") ?? .yellow,
            "onSurface3": Color(hex: "#FFE0B2") ?? .orange,
            "accent1": Color(hex: "#FF8A65") ?? .orange,
            "accent2": Color(hex: "#FFAB91") ?? .orange,
            "accent3": Color(hex: "#3E2723") ?? .black,
            "accent4": Color(hex: "#A1887F") ?? .brown,
            "accent5": Color(hex: "#261A16") ?? .black,
            "accentContainer1": Color(hex: "#3E2723") ?? .black,
            "onAccent1": Color(hex: "#FFFFFF") ?? .white,
            "error1": Color(hex: "#FF5252") ?? .red,
            "errorContainer1": Color(hex: "#5D1A1A") ?? .red
        ],
        previewColors: [
            Color(hex: "#8D6E63") ?? .brown,
            Color(hex: "#FF8A65") ?? .orange,
            Color(hex: "#FFCC80") ?? .orange,
            Color(hex: "#FFF8E1") ?? .yellow
        ]
    )
    
    // MARK: - All Presets
    
    static let allPresets: [ThemePreset] = [
        .defaultSalesforce,
        .forest,
        .botanical,
        .tropicalRainforest,
        .desert
    ]
}

