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

/// A featured matcha product on the storefront. Sample data — the photography lives
/// in `Assets.xcassets` (see `imageName`). No prices, per the design direction.
struct Product: Identifiable {
    let id = UUID()
    /// Product name, shown in serif (e.g. "Ceremonial Matcha").
    let name: String
    /// Short uppercase grade badge overlaid on the image (e.g. "CEREMONIAL").
    let badge: String
    /// Short tasting note (e.g. "Smooth & balanced").
    let tasting: String
    /// One-line use description shown beside the leaf mark.
    let note: String
    /// Asset-catalog image name for the product photography.
    let imageName: String
}

extension Product {
    static let featured: [Product] = [
        Product(name: "Ceremonial Matcha",
                badge: "CEREMONIAL",
                tasting: "Smooth & balanced",
                note: "For traditional preparation and mindful moments.",
                imageName: "product_ceremonial"),
        Product(name: "Culinary Matcha",
                badge: "CULINARY",
                tasting: "Rich & vibrant",
                note: "Perfect for lattes, smoothies and everyday.",
                imageName: "product_culinary"),
    ]
}
