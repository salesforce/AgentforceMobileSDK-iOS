# 🍵 Kiko's Matcha Shop — AgentforceSDK Sample App

A SwiftUI iOS sample app demonstrating best practices for integrating the
[AgentforceMobileSDK](https://github.com/salesforce/AgentforceMobileSDK-iOS). Kiko's Matcha Shop
is a minimal, premium, Japanese-inspired matcha storefront whose AI assistant, **Kiko**, answers
questions about matcha, orders, and brewing. The app showcases guest authentication,
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
  stock `TabView`, plus a split floating "Ask Kiko" launcher (tap the label to chat, the mic to talk)
- 💬 **Conversational AI** — a full chat interface with Kiko, the shop's matcha expert
- 🔑 **Guest authentication** — full (`.fullConfig`) guest auth using your org's My Domain URL and
  an Agent ID; the SDK resolves everything else, so there are no OAuth tokens to manage
- 🎨 **Custom Brand Theming** — a warm-white + dark-forest-green palette with serif typography,
  applied to both the app UI and the in-chat Agentforce surface via the SDK theming API
- 🗣️ **Voice conversations** — voice is enabled (`enableVoice: true`); the mic side of the
  "Ask Kiko" launcher starts a live voice session
- ⚡ **Clean architecture** — dependency injection, MVVM, and `@Observable` settings

This app is a **reference implementation** for developers integrating AgentforceSDK into their
own applications.

## 🎨 Brand

- **Kiko** — the shop's AI assistant, reached through the split floating "Ask Kiko" launcher
  (label → chat, mic → voice)
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
│   └── KikoSettings.swift                    # @Observable settings + guest auth config
│
├── SDKIntegration/
│   ├── KikoAgentforceClient.swift            # SDK wrapper + guest .fullConfig setup
│   ├── KikoCredentialProvider.swift          # Guest auth credential provider
│   ├── KikoDelegate.swift                     # UI delegate + analytics
│   ├── KikoThemeManager.swift                 # App-wide SwiftUI theme (KikoTheme)
│   └── CustomMatchaViewProvider.swift         # Custom view provider example
│
├── Features/
│   ├── Home/    (HomeView, HomeViewModel,     # Storefront: hero + featured grid + chat entry
│   │            Product)                        # Featured-product model (Ceremonial/Culinary)
│   └── Chat/    (ChatView, ChatViewModel)     # Example MVVM chat wrapper (not on the live path)
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

### Configure the agent

Launch the app, tap the **menu (☰)** button in the top-left of the Home header to open
**Settings**, and fill in:

- **My Domain URL** — your org's My Domain URL (e.g. `https://mycompany.my.salesforce.com`).
  Guest auth resolves everything else from here, so this is required.
- **Agent ID** — the Agentforce Agent ID the conversation runs against (required).
- **SFAP URL** — *optional*; leave blank to use the public `https://api.salesforce.com` gateway.

Settings are persisted with `UserDefaults` and applied when you close the Settings sheet — no app
restart required.

## 📚 Integration guide

### 1. Build the guest (`.fullConfig`) configuration

```swift
// KikoAgentforceClient.swift
// Guest auth doesn't identify a real user, so these fields are empty; only the
// display name is surfaced in the UI.
let user = User(userId: "", org: Org(id: ""), username: "", displayName: "Matcha Enthusiast")

let configuration = AgentforceConfiguration(
    user: user,
    authProvider: KikoCredentialProvider(forceConfigEndpoint: settings.forceConfigEndpoint),
    forceConfigEndpoint: settings.forceConfigEndpoint,     // org My Domain URL
    agentforceFeatureFlagSettings: settings.createFeatureFlagSettings(),  // enableVoice: true
    agentforceConnectionInfo: AgentforceConnectionInfo(
        sfapURL: settings.effectiveSFAPURL,
        tenantId: ""
    ),
    salesforceNetwork: nil,
    salesforceNavigation: nil,
    themeManager: settings.createThemeManager()            // BrandTheme.themeManager(mode:)
).setTheming(BrandTheme.theming)   // layer forest-green brand colors onto the chat UI
```

### 2. Create the client

```swift
agentforceClient = AgentforceClient(
    mode: .fullConfig(configuration),
    viewProvider: CustomMatchaViewProvider()
)
```

### 3. Start a conversation, create UI

```swift
let conversation = agentforceClient.startAgentforceConversation(
    forAgentId: settings.agentId
)

let chatView = try client.createAgentforceChatView(
    conversation: conversation,
    delegate: delegate,
    showTopBar: true,
    onContainerClose: { /* handle close */ }
)

// This sample presents `chatView` from a custom split floating "Ask Kiko" launcher
// (see `ContentView.swift`), but the SDK's launcher is also available:
if #available(iOS 26.0, *) {
    let launcher = client.createAgentforceLauncher(
        chatView: chatView,
        launchChatView: { /* present chat */ }
    )
}
```

### 4. (Optional) Start a voice conversation

Voice requires `AgentforceFeatureFlagSettings(enableVoice: true)` (set in
`createFeatureFlagSettings()`) and the microphone permission
(`NSMicrophoneUsageDescription`, supplied here as a build setting).

```swift
let voiceView = try client.createAgentforceVoiceView(
    conversation: conversation,
    onContainerClose: { /* handle close */ }
)
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
     `AgentforceConfiguration.setTheming(_:)`.

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

- [AgentforceMobileSDK-iOS](https://github.com/salesforce/AgentforceMobileSDK-iOS)
- [Salesforce Developer Guide](https://developer.salesforce.com)
- [Agentforce Documentation](https://developer.salesforce.com/docs/einstein/genai)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

---

**Built to demonstrate AgentforceSDK integration patterns — now with more matcha. 🍵**
