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
struct KikoTheme {
    
    // MARK: - Color Palette
    
    struct Colors {
        let colorScheme: ColorScheme
        
        init(colorScheme: ColorScheme) {
            self.colorScheme = colorScheme
        }
        
        // Primary brand color - dark forest green
        var brand: Color {
            colorScheme == .dark
                ? Color(red: 0.62, green: 0.74, blue: 0.55)  // Soft sage in dark mode
                : Color(red: 0.086, green: 0.196, blue: 0.125)  // Dark forest green
        }

        var brandLight: Color {
            colorScheme == .dark
                ? Color(red: 0.72, green: 0.83, blue: 0.66)
                : Color(red: 0.18, green: 0.31, blue: 0.22)
        }

        var brandDark: Color {
            colorScheme == .dark
                ? Color(red: 0.50, green: 0.62, blue: 0.44)
                : Color(red: 0.05, green: 0.13, blue: 0.09)
        }

        // Secondary accent - the same forest green (no secondary hue, per the design direction)
        var accent: Color {
            colorScheme == .dark
                ? Color(red: 0.62, green: 0.74, blue: 0.55)
                : Color(red: 0.086, green: 0.196, blue: 0.125)
        }

        var accentLight: Color {
            colorScheme == .dark
                ? Color(red: 0.72, green: 0.83, blue: 0.66)
                : Color(red: 0.18, green: 0.31, blue: 0.22)
        }

        // Surface colors - warm white canvas
        var surface1: Color {
            colorScheme == .dark
                ? Color(red: 0.106, green: 0.114, blue: 0.106)  // Warm charcoal
                : Color(red: 0.972, green: 0.964, blue: 0.953)  // Warm white
        }

        var surface2: Color {
            colorScheme == .dark
                ? Color(red: 0.145, green: 0.153, blue: 0.141)
                : Color(red: 0.945, green: 0.937, blue: 0.922)  // Warm dim
        }

        var surface3: Color {
            colorScheme == .dark
                ? Color(red: 0.196, green: 0.204, blue: 0.188)
                : Color(red: 0.918, green: 0.909, blue: 0.890)
        }

        // Text colors
        var textPrimary: Color {
            colorScheme == .dark
                ? Color(red: 0.960, green: 0.956, blue: 0.945)  // Warm near-white
                : Color(red: 0.114, green: 0.141, blue: 0.118)  // Forest ink
        }

        var textSecondary: Color {
            colorScheme == .dark
                ? Color(red: 0.706, green: 0.694, blue: 0.671)
                : Color(red: 0.451, green: 0.435, blue: 0.412)  // Warm gray
        }

        var textDisabled: Color {
            colorScheme == .dark
                ? Color(red: 0.45, green: 0.44, blue: 0.42)
                : Color(red: 0.686, green: 0.671, blue: 0.647)
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
        
        // Border colors - warm hairline
        var border: Color {
            colorScheme == .dark
                ? Color(red: 0.29, green: 0.30, blue: 0.28)
                : Color(red: 0.850, green: 0.840, blue: 0.812)
        }

        var borderFocused: Color { brand }

        // Card colors
        var cardBackground: Color {
            colorScheme == .dark
                ? Color(red: 0.145, green: 0.153, blue: 0.141)
                : Color(red: 0.972, green: 0.964, blue: 0.953)
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
    static let defaultValue: KikoTheme.Colors? = nil
}

extension EnvironmentValues {
    var themeColors: KikoTheme.Colors? {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply theme colors to the view hierarchy
    func withThemeColors(_ colors: KikoTheme.Colors) -> some View {
        self.environment(\.themeColors, colors)
    }
    
    func kikoPrimaryButton(colors: KikoTheme.Colors) -> some View {
        self
            .font(KikoTheme.Typography.button)
            .foregroundColor(.white)
            .padding(.horizontal, KikoTheme.Spacing.lg)
            .padding(.vertical, KikoTheme.Spacing.md)
            .background(colors.brand)
            .clipShape(RoundedRectangle(cornerRadius: KikoTheme.CornerRadius.sm))
    }
}
