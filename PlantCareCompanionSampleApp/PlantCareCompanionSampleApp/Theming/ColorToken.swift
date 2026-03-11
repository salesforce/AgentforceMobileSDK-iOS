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

// MARK: - Color Token Enum

/// Enum representing color tokens actually used in UI customization
enum ColorToken: String, CaseIterable {
    // Core surface colors - most frequently used
    case surface1 // Main backgrounds, cards
    case surface2 // Secondary backgrounds
    case surfaceContainer1 // Component backgrounds
    case surfaceContainer2 // Component backgrounds (medium)
    case surfaceContainer3 // Borders, dividers
    
    // Essential text colors
    case onSurface1 // Primary text
    case onSurface2 // Secondary text
    case onSurface3 // Tertiary text, icons
    
    // Interactive colors
    case accent1 // Primary accent color
    case accent2 // Buttons, links, interactive elements
    case accent3 // Additional accent variant
    case accent4 // Additional accent variant
    case accent5 // Additional accent variant
    case accentContainer1 // Button backgrounds
    case onAccent1 // Text on accent backgrounds
    
    // Feedback colors
    case error1 // Error text
    case errorContainer1 // Error backgrounds
    case onError1 // Text on error backgrounds
    
    // Border colors
    case border1 // Decorative borders
    case borderError1 // Error borders
    
    // Disabled state colors
    case disabledContainer1 // Disabled background
    case onDisabled1 // Disabled text 1
    case onDisabled2 // Disabled text 2
    
    var displayName: String {
        // Return the exact property name as used in code
        rawValue
    }
    
    var category: ColorCategory {
        switch self {
        case .surface1, .surface2:
            return .surface
        case .onSurface1, .onSurface2, .onSurface3:
            return .textAndIcons
        case .surfaceContainer1, .surfaceContainer2, .surfaceContainer3:
            return .containers
        case .accent1, .accent2, .accent3, .accent4, .accent5, .accentContainer1, .onAccent1:
            return .accent
        case .error1, .errorContainer1, .onError1:
            return .error
        case .border1, .borderError1:
            return .borders
        case .disabledContainer1, .onDisabled1, .onDisabled2:
            return .disabled
        }
    }
}

// MARK: - Color Category Enum

enum ColorCategory: String, CaseIterable {
    case surface = "Surface Colors"
    case textAndIcons = "Text & Icons"
    case containers = "Container Colors"
    case accent = "Accent Colors"
    case borders = "Border Colors"
    case error = "Error Colors"
    case disabled = "Disabled State"
    
    var description: String {
        switch self {
        case .surface: return "Main background colors"
        case .textAndIcons: return "Text and icon colors"
        case .containers: return "Component containers & borders"
        case .accent: return "Interactive & brand colors"
        case .borders: return "Border and divider colors"
        case .error: return "Error state colors"
        case .disabled: return "Disabled state colors"
        }
    }
    
    var tokens: [ColorToken] {
        ColorToken.allCases.filter { $0.category == self }
    }
    
    var icon: String {
        switch self {
        case .surface: return "rectangle.fill"
        case .textAndIcons: return "textformat"
        case .containers: return "square.stack.3d.down.right"
        case .accent: return "paintbrush.pointed.fill"
        case .borders: return "line.3.horizontal"
        case .error: return "exclamationmark.triangle.fill"
        case .disabled: return "nosign"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .surface: return .blue
        case .textAndIcons: return .purple
        case .containers: return .green
        case .accent: return .pink
        case .borders: return .orange
        case .error: return .red
        case .disabled: return .gray
        }
    }
}

// MARK: - Color Extensions

extension Color {
    /// Convert Color to hex string
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return nil }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
    
    /// Initialize Color from hex string
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

