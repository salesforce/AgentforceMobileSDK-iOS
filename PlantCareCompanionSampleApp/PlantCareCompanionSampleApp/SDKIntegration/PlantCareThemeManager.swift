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

// MARK: - App-Wide Theme (for non-SDK views)

/// Simplified theme for app views that don't use the SDK theme system
struct PlantCareTheme {
    
    // MARK: - Color Palette
    
    struct Colors {
        let colorScheme: ColorScheme
        
        init(colorScheme: ColorScheme) {
            self.colorScheme = colorScheme
        }
        
        // Primary colors - Nature inspired greens
        var brand: Color {
            colorScheme == .dark
                ? Color(red: 0.40, green: 0.79, blue: 0.41)  // Brighter in dark mode
                : Color(red: 0.30, green: 0.69, blue: 0.31)  // Leafy green
        }
        
        var brandLight: Color {
            colorScheme == .dark
                ? Color(red: 0.50, green: 0.89, blue: 0.51)
                : Color(red: 0.40, green: 0.79, blue: 0.41)
        }
        
        var brandDark: Color {
            colorScheme == .dark
                ? Color(red: 0.30, green: 0.69, blue: 0.31)
                : Color(red: 0.20, green: 0.59, blue: 0.21)
        }
        
        // Surface colors
        var surface1: Color {
            colorScheme == .dark
                ? Color(red: 0.11, green: 0.11, blue: 0.12)  // Dark background
                : Color(red: 0.98, green: 0.98, blue: 0.97)  // Warm off-white
        }
        
        var surface2: Color {
            colorScheme == .dark
                ? Color(red: 0.15, green: 0.16, blue: 0.15)  // Darker surface
                : Color(red: 0.95, green: 0.97, blue: 0.95)  // Subtle green tint
        }
        
        var surface3: Color {
            colorScheme == .dark
                ? Color(red: 0.20, green: 0.22, blue: 0.20)
                : Color(red: 0.91, green: 0.94, blue: 0.91)
        }
        
        // Text colors
        var textPrimary: Color {
            colorScheme == .dark
                ? Color(red: 0.95, green: 0.95, blue: 0.95)  // Near white
                : Color(red: 0.20, green: 0.29, blue: 0.20)  // Dark green
        }
        
        var textSecondary: Color {
            colorScheme == .dark
                ? Color(red: 0.70, green: 0.75, blue: 0.70)
                : Color(red: 0.40, green: 0.50, blue: 0.40)
        }
        
        var textDisabled: Color {
            colorScheme == .dark
                ? Color(red: 0.45, green: 0.45, blue: 0.45)
                : Color(red: 0.70, green: 0.75, blue: 0.70)
        }
        
        // Semantic colors
        var success: Color { brand }
        
        var warning: Color {
            colorScheme == .dark
                ? Color(red: 0.98, green: 0.85, blue: 0.28)
                : Color(red: 0.98, green: 0.75, blue: 0.18)
        }
        
        var error: Color {
            colorScheme == .dark
                ? Color(red: 0.94, green: 0.28, blue: 0.28)
                : Color(red: 0.84, green: 0.18, blue: 0.18)
        }
        
        var info: Color {
            colorScheme == .dark
                ? Color(red: 0.23, green: 0.69, blue: 1.0)
                : Color(red: 0.13, green: 0.59, blue: 0.95)
        }
        
        // Border colors
        var border: Color {
            colorScheme == .dark
                ? Color(red: 0.30, green: 0.32, blue: 0.30)
                : Color(red: 0.85, green: 0.89, blue: 0.85)
        }
        
        var borderFocused: Color { brand }
        
        // Card colors
        var cardBackground: Color {
            colorScheme == .dark
                ? Color(red: 0.18, green: 0.19, blue: 0.18)
                : Color.white
        }
        
        var cardShadow: Color {
            Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08)
        }
        
        // Static convenience accessors for backward compatibility
        static func color(for scheme: ColorScheme) -> Colors {
            Colors(colorScheme: scheme)
        }
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 24, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let button = Font.system(size: 16, weight: .medium, design: .rounded)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadow
    
    struct Shadow {
        let colors: Colors
        
        var small: ShadowStyle {
            ShadowStyle(color: colors.cardShadow, radius: 2, x: 0, y: 1)
        }
        
        var medium: ShadowStyle {
            ShadowStyle(color: colors.cardShadow, radius: 4, x: 0, y: 2)
        }
        
        var large: ShadowStyle {
            ShadowStyle(color: colors.cardShadow, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Shadow Helper

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Environment Key for Theme Colors

private struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue: PlantCareTheme.Colors? = nil
}

extension EnvironmentValues {
    var themeColors: PlantCareTheme.Colors? {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply theme colors to the view hierarchy
    func withThemeColors(_ colors: PlantCareTheme.Colors) -> some View {
        self.environment(\.themeColors, colors)
    }
    
    func plantCarePrimaryButton(colors: PlantCareTheme.Colors) -> some View {
        self
            .font(PlantCareTheme.Typography.button)
            .foregroundColor(.white)
            .padding(.horizontal, PlantCareTheme.Spacing.lg)
            .padding(.vertical, PlantCareTheme.Spacing.md)
            .background(colors.brand)
            .clipShape(RoundedRectangle(cornerRadius: PlantCareTheme.CornerRadius.sm))
    }
}
