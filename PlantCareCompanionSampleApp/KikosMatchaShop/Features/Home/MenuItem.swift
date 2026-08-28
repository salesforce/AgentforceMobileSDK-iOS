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
import Foundation

/// A single item on Kiko's Matcha Shop menu. This is sample data used to give the
/// Home screen a real storefront feel — the illustrations live in `Assets.xcassets`
/// (see `imageName`) and were generated with Core Graphics.
struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let tagline: String
    let price: String
    /// Asset-catalog image name for the item's illustration.
    let imageName: String
    let category: Category

    enum Category: String, CaseIterable, Identifiable {
        case drinks = "Signature Matcha"
        case sweets = "Sweets & Treats"
        var id: String { rawValue }
    }
}

extension MenuItem {
    /// The full (fictional) menu for the shop.
    static let menu: [MenuItem] = [
        // Signature Matcha
        MenuItem(name: "Iced Matcha Latte",
                 tagline: "Stone-ground ceremonial matcha over cold oat milk.",
                 price: "$5.75", imageName: "menu_iced_matcha", category: .drinks),
        MenuItem(name: "Kiko's Matcha Latte",
                 tagline: "Our house classic, whisked warm with a leaf on top.",
                 price: "$5.25", imageName: "menu_matcha_latte", category: .drinks),
        MenuItem(name: "Strawberry Matcha",
                 tagline: "Layers of fresh strawberry purée, milk, and matcha.",
                 price: "$6.50", imageName: "menu_strawberry_matcha", category: .drinks),
        MenuItem(name: "Iced Hojicha Oat Latte",
                 tagline: "Roasty, toasty hojicha with silky oat milk.",
                 price: "$5.50", imageName: "menu_hojicha_latte", category: .drinks),
        MenuItem(name: "Sparkling Matcha Lemonade",
                 tagline: "Bright, fizzy, and refreshing with a matcha swirl.",
                 price: "$5.00", imageName: "menu_matcha_lemonade", category: .drinks),
        // Sweets & Treats
        MenuItem(name: "Matcha Soft Serve",
                 tagline: "Creamy matcha swirl in a crisp waffle cone.",
                 price: "$4.75", imageName: "menu_soft_serve", category: .sweets),
        MenuItem(name: "Matcha White-Choc Cookie",
                 tagline: "Chewy cookie loaded with white chocolate chunks.",
                 price: "$3.50", imageName: "menu_matcha_cookie", category: .sweets),
        MenuItem(name: "Matcha Croissant",
                 tagline: "Flaky, buttery pastry with a matcha glaze drizzle.",
                 price: "$4.25", imageName: "menu_matcha_croissant", category: .sweets),
    ]

    static func items(in category: Category) -> [MenuItem] {
        menu.filter { $0.category == category }
    }
}
