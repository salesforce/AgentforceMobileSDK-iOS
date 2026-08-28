# 🍵 Kiko's Matcha Shop — AgentforceSDK Sample App

A SwiftUI iOS sample app demonstrating best practices for integrating the
[AgentforceSDK](https://github.com/salesforce/AgentforceSDK-iOS). Kiko's Matcha Shop is a
minimal, premium, Japanese-inspired matcha storefront whose AI assistant, **Kiko**, answers
questions about matcha, orders, and brewing. The app showcases Service Agent mode,
conversational AI, custom brand theming, and a floating voice assistant — all wired up with
Swift Package Manager.

![Platform](https://img.shields.io/badge/platform-iOS%2018.6%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/license-BSD--3-green)

## 📋 Overview

Kiko's Matcha Shop demonstrates:
- 🛍️ **Premium storefront** — a Home screen with a full-bleed hero and a clean two-column
  featured-product grid (Ceremonial & Culinary matcha), using real matcha photography
- 🧭 **Custom navigation** — a bespoke bottom bar (Home · Shop · Learn · Orders) instead of a
  stock `TabView`, plus a small floating "Ask Kiko" voice button
- 💬 **Conversational AI** — a full chat interface with Kiko, the shop's matcha expert
- ⚙️ **Service Agent Mode** — Service Agent deployment configuration and initialization
- 🎨 **Custom Brand Theming** — a warm-white + dark-forest-green palette with serif typography,
  applied to both the app UI and the in-chat Agentforce surface via the SDK theming API
- 🗣️ **Voice-ready configuration** — optional My Domain endpoint for voice conversations
- ⚡ **Clean architecture** — dependency injection, MVVM, and `@Observable` settings

This app is a **reference implementation** for developers integrating AgentforceSDK into their
own applications.

## 🎨 Brand

- **Kiko** — the shop's AI assistant, reached through the floating "Ask Kiko" voice button
- **Aesthetic** — minimal, premium, and Japanese-inspired: a warm-white canvas, dark
  forest-green accents, and serif typography (New York) for the wordmark, headlines, and
  product names. No gradients, minimal corner rounding, no heavy shadows.
- **Primary color** — dark forest green (`#16321F`-ish) on a warm off-white (`#F8F6F3`-ish)
- **Design system** — `Theming/MatchaStyle.swift` is the single source of truth for the
  storefront palette, serif fonts, and metrics
- **Photography** — the hero and product imagery live as imagesets in `Assets.xcassets`
  (`hero_matcha`, `product_ceremonial`, `product_culinary`)

## 🏗️ Architecture

### Project structure

```
KikosMatchaShop.xcodeproj                    # Xcode project (Swift Package Manager)
KikosMatchaShop/
├── Models/
│   ├── KikoError.swift                       # Error types and user-facing messages
│   └── KikoSettings.swift                    # @Observable settings + Service config
│
├── SDKIntegration/
│   ├── KikoAgentforceClient.swift            # SDK wrapper + Service Agent setup
│   ├── KikoCredentialProvider.swift          # Authentication provider (mock)
│   ├── KikoDelegate.swift                     # UI delegate + analytics
│   ├── KikoThemeManager.swift                 # App-wide SwiftUI theme (KikoTheme)
│   └── CustomMatchaViewProvider.swift         # Custom view provider example
│
├── Features/
│   ├── Home/    (HomeView, HomeViewModel,     # Storefront: hero + featured grid + chat entry
│   │            Product)                        # Featured-product model (Ceremonial/Culinary)
│   └── Chat/    (ChatView, ChatViewModel)     # Chat interface wrapper
│
├── Theming/
│   ├── MatchaStyle.swift                        # Storefront design system (palette/serif/metrics)
│   └── BrandTheme.swift                        # SDK chat theming (forest-green tokens)
│
├── CompositionRoot.swift                       # Dependency injection container
├── ContentView.swift                           # Custom scaffold: bottom nav + floating Ask Kiko
├── SettingsView.swift                          # Service + theme configuration UI (sheet)
└── KikosMatchaShopApp.swift                    # App entry point

KikosMatchaShopTests/                           # Unit tests
KikosMatchaShopUITests/                         # UI tests
```

### Design patterns

- **CompositionRoot** — centralizes creation of `KikoSettings`, `KikoCredentialProvider`, and
  `KikoAgentforceClient`, and vends view models.
- **MVVM** — SwiftUI views with `@Observable` view models (`HomeViewModel`, `ChatViewModel`).
- **Provider pattern** — `KikoCredentialProvider` (auth), `KikoDelegate` (UI events),
  `CustomMatchaViewProvider` (custom views).

## 🚀 Getting started

### Prerequisites

- Xcode 26+
- iOS 18.6+ deployment target
- Swift 5.0+
- A Salesforce org with Agentforce configured (for full functionality)

### Dependencies (Swift Package Manager)

This app has **no CocoaPods** — dependencies are resolved entirely through SPM. The project
references the AgentforceSDK package locally (`XCLocalSwiftPackageReference` → `..`) and links
the `AgentforceSDK` and `AgentforceVoice` products. Xcode resolves the package graph
automatically on open.

### Build and run

```bash
# Open in Xcode
open KikosMatchaShop.xcodeproj

# …or build from the command line
xcodebuild -project KikosMatchaShop.xcodeproj \
           -scheme KikosMatchaShop \
           -destination 'generic/platform=iOS Simulator' \
           build
```

### Configure the Service Agent

Launch the app, tap the **menu (☰)** button in the top-left of the Home header to open
**Settings**, and fill in:

- **Service API URL** — your Service Agent endpoint
- **Organization ID** — your Salesforce org ID
- **Developer Name** — the Service Agent's ES developer name
- **My Domain URL (for voice)** — *optional*; only required for voice conversations. Chat works
  without it.

Settings are persisted with `UserDefaults`. Restart the app to apply changes.

## 📚 Integration guide

### 1. Build the Service Agent configuration

```swift
// KikoSettings.swift
func createServiceDeploymentConfig() -> ServiceAgentConfiguration? {
    // …validate required fields…
    return ServiceAgentConfiguration(
        esDeveloperName: developerName,
        organizationId: organizationId,
        serviceApiURL: serviceAPI,
        serviceUISettings: ServiceUISettings(),
        forceConfigEndPoint: forceConfigEndpoint   // org My Domain URL; needed for voice
    )
}
```

### 2. Apply brand theming and initialize the client

```swift
// KikoAgentforceClient.swift
let themeManager = settings.createThemeManager()     // BrandTheme.themeManager(mode:)
let viewProvider = CustomMatchaViewProvider()

guard let serviceConfig = settings.createServiceDeploymentConfig() else { return }

// Layer brand color overrides (forest green) onto the chat UI.
let themedConfig = serviceConfig.setTheming(BrandTheme.theming)

agentforceClient = AgentforceClient(
    credentialProvider: credentialProvider,
    mode: .serviceAgent(themedConfig),
    viewProvider: viewProvider,
    themeManager: themeManager
)
```

### 3. Start a conversation, create UI

```swift
let conversation = agentforceClient.startAgentforceConversation(
    forESDeveloperName: themedConfig.esDeveloperName
)

let chatView = try client.createAgentforceChatView(
    conversation: conversation,
    delegate: delegate,
    showTopBar: true,
    onContainerClose: { /* handle close */ }
)

// This sample presents `chatView` from a custom floating "Ask Kiko" voice button
// (see `ContentView.swift`), but the SDK's launcher is also available:
if #available(iOS 26.0, *) {
    let launcher = client.createAgentforceLauncher(
        chatView: chatView,
        launchChatView: { /* present chat */ }
    )
}
```

## 🎨 Theming

The app themes two surfaces, both built on the same warm-white + dark-forest-green palette:

1. **Storefront UI** — `MatchaStyle` (in `Theming/MatchaStyle.swift`) is the design system for
   the shop itself: the color tokens (`warmWhite`, `forest`, `ink`, `muted`, `hairline`, …), the
   `serif(_:_:)` font helper, and the layout metrics. The storefront runs in a fixed light
   appearance for a consistent premium look. (`KikoTheme` in `KikoThemeManager.swift` remains as
   a light/dark SwiftUI palette for the Settings surface and is tuned to the same colors.)

2. **Agentforce chat UI** — `BrandTheme` (in `BrandTheme.swift`) owns both theming inputs the
   SDK exposes:
   - `themeManager(mode:)` → `AgentforceDefaultThemeManager(themeMode:)` drives light/dark.
   - `theming` → `AgentforceTheming.overrides(light:dark:)` maps `AgentforceColorToken`s to the
     forest-green brand color (title bar, user bubbles, send button, launcher, agent avatar,
     primary response buttons, and voice button). Applied via
     `ServiceAgentConfiguration.setTheming(_:)`.

   Any token left unspecified falls back to the SDK default — edit the `brandColors` map in
   `BrandTheme.swift` to customize further.

## 🧪 Testing

```bash
xcodebuild test -project KikosMatchaShop.xcodeproj \
                -scheme KikosMatchaShop \
                -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 📄 License

Provided under the BSD-3-Clause License. See the repository `LICENSE` file for details.

## 🔗 Resources

- [AgentforceSDK-iOS](https://github.com/salesforce/AgentforceSDK-iOS)
- [Salesforce Developer Guide](https://developer.salesforce.com)
- [Agentforce Documentation](https://developer.salesforce.com/docs/einstein/genai)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

---

**Built to demonstrate AgentforceSDK integration patterns — now with more matcha. 🍵**
