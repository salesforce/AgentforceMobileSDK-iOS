# 🌱 Plant Care Companion - AgentforceSDK Sample App

A comprehensive iOS sample application demonstrating best practices for integrating the [AgentforceSDK](https://github.com/salesforce/AgentforceSDK-iOS). Built with SwiftUI, this app showcases Service Agent mode, conversational AI, multi-modal input, custom theming, and iOS 26 launcher integration.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-BSD--3-green)

## 📋 Overview

Plant Care Companion is an AI-powered plant care assistant that demonstrates:
- 💬 **Conversational AI** - Full-featured chat interface with plant expert
- 📸 **Multi-Modal Input** - Text and image attachments for plant identification
- ⚙️ **Service Agent Mode** - Service Agent deployment configuration
- 🚀 **iOS 26 Launcher** - Tab bar accessory with launcher integration
- 🎨 **Custom Theming** - Advanced theme customization with color pickers
- ⚡ **Best Practices** - Clean architecture, dependency injection, and proper SDK usage

This app serves as a **reference implementation** for developers integrating AgentforceSDK into their own applications.

## ✨ Key Features Demonstrated

### SDK Integration Patterns

- ✅ **Service Agent Mode** - Service Agent deployment configuration and initialization
- ✅ **Conversation Management** - Starting conversations with Service Agent developer name
- ✅ **Multi-Modal Input** - Text and image attachments for plant identification
- ✅ **Custom Theming** - Advanced theme system with light/dark/system modes
- ✅ **UI Components** - AgentforceChatView and AgentforceLauncher (iOS 26+)
- ✅ **Error Handling** - Comprehensive error types and user feedback
- ✅ **Dependency Injection** - Clean architecture with CompositionRoot
- ✅ **Settings Management** - Persistent configuration with @Observable pattern
- ✅ **Custom View Provider** - Demonstrates view customization capabilities
- ✅ **Analytics Integration** - Event tracking and instrumentation

### Application Features

- 🏠 **Home Screen** - Welcome interface with Service Agent configuration status
- 💬 **AI Chat Interface** - Full-featured conversational UI with the plant expert
- 🚀 **iOS 26 Launcher** - Tab bar accessory for quick chat access
- ⚙️ **Settings Panel** - Configure Service Agent deployment, theme modes, and feature flags
- 🎨 **Advanced Theme Editor** - Customizable color tokens with live preview
- 📊 **Analytics Tracking** - Built-in event tracking for monitoring

## 🏗️ Architecture

### Project Structure

```
PlantCareCompanionSampleApp/
├── Models/
│   ├── PlantCareError.swift                # Error types and user-friendly messages
│   └── PlantCareSettings.swift             # Settings management with @Observable
│
├── SDKIntegration/
│   ├── PlantCareAgentforceClient.swift     # Main SDK wrapper with Service Agent setup
│   ├── PlantCareCredentialProvider.swift   # Authentication provider
│   ├── PlantCareDelegate.swift             # UI delegate and analytics handler
│   ├── PlantCareThemeManager.swift         # Base theme configuration
│   └── CustomPlantViewProvider.swift       # Custom view provider example
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift                  # Home screen with Service Agent status
│   │   └── HomeViewModel.swift             # Home screen logic
│   └── Chat/
│       ├── ChatView.swift                  # Chat interface wrapper
│       └── ChatViewModel.swift             # Chat state management
│
├── Theming/
│   ├── ColorToken.swift                    # Customizable color tokens
│   ├── CustomizableColors.swift            # Advanced color system
│   ├── CustomizableThemeManager.swift      # Theme manager with mode support
│   └── ThemePresets.swift                  # Built-in theme presets
│
├── CompositionRoot.swift                   # Dependency injection container
├── ContentView.swift                       # Main tab navigation with launcher
├── SettingsView.swift                      # Settings configuration UI
└── PlantCareCompanionSampleAppApp.swift   # App entry point
```

### Design Patterns

#### 1. **CompositionRoot Pattern**
Centralizes dependency creation and management:

```swift
@MainActor
class CompositionRoot: ObservableObject {
    let settings: PlantCareSettings
    let credentialProvider: PlantCareCredentialProvider
    @Published var agentforceClient: PlantCareAgentforceClient
    
    init() {
        self.settings = PlantCareSettings()
        self.credentialProvider = PlantCareCredentialProvider()
        self.agentforceClient = PlantCareAgentforceClient(
            credentialProvider: credentialProvider,
            settings: settings
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(agentforceClient: agentforceClient, compositionRoot: self)
    }
}
```

#### 2. **MVVM (Model-View-ViewModel)**
Each feature uses MVVM for clean separation:
- **Model**: `PlantCareSettings`, `PlantCareError`
- **View**: SwiftUI views with declarative UI (`HomeView`, `ChatView`, `SettingsView`)
- **ViewModel**: `@Observable` classes managing state and business logic

#### 3. **Provider Pattern**
Custom providers for extensibility:
- `PlantCareCredentialProvider` - Authentication (implements `AgentforceAuthCredentialProviding`)
- `PlantCareDelegate` - UI event handling (implements `AgentforceUIDelegate`)
- `CustomizableThemeManager` - Visual customization (implements `AgentforceThemeManaging`)
- `CustomPlantViewProvider` - Custom view provider (implements `AgentforceViewProviding`)

#### 4. **@Observable Pattern**
Modern Swift concurrency with @Observable:
- `PlantCareSettings` uses `@Observable` for reactive configuration
- Automatic UI updates when settings change
- No need for manual `@Published` property wrappers

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- Swift 5.9+
- Salesforce org with Agentforce configured (for full functionality)

### Installation

1. **Clone the Repository**
   ```bash
   cd /Users/scotland.peters/Development/PlantCareCompanionSampleApp
   ```

2. **Add AgentforceSDK Dependency**
   
   The app uses CocoaPods to integrate with AgentforceSDK:
   
   ```bash
   # Install dependencies
   pod install
   
   # Open the workspace
   open PlantCareCompanionSampleApp.xcworkspace
   ```
   
   **Alternative: Local Development**
   If you have the AgentforceSDK source locally:
   ```
   In Podfile, update the path:
   pod 'AgentforceSDK', :path => '../AgentforceSDK'
   ```

3. **Configure Service Agent Settings**

   Launch the app and navigate to the **Settings** tab to configure:
   - **Service API URL**: Your Service Agent endpoint (e.g., `https://your-service-agent.com/api`)
   - **Organization ID**: Your Salesforce organization ID
   - **Developer Name**: The Service Agent's developer name (e.g., `PlantCareExpert`)
   
   These settings are persisted using UserDefaults.

4. **Build and Run**
   ```bash
   # Open workspace in Xcode
   open PlantCareCompanionSampleApp.xcworkspace
   
   # Or build from command line
   xcodebuild -workspace PlantCareCompanionSampleApp.xcworkspace \
              -scheme PlantCareCompanionSampleApp \
              -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
   ```

5. **Test on iOS 26 (for Launcher)**
   
   To test the launcher feature, use an iOS 26+ simulator or device:
   ```bash
   xcrun simctl list | grep "iOS 26"
   ```

## 📚 Integration Guide

### Step 1: Configure Service Agent Settings

```swift
// In PlantCareSettings.swift
@Observable
class PlantCareSettings {
    var serviceAgentAPI: String = ""        // e.g., "https://your-service.com/api"
    var serviceAgentOrganizationId: String = ""    // Your Salesforce org ID
    var serviceAgentDeveloperName: String = ""     // Service Agent developer name

    func createServiceAgentDeploymentConfig() -> ServiceAgentConfiguration? {
        guard !serviceAgentAPI.isEmpty,
              !serviceAgentOrganizationId.isEmpty,
              !serviceAgentDeveloperName.isEmpty else {
            return nil
        }

        return ServiceAgentConfiguration(
            esDeveloperName: serviceAgentDeveloperName,
            organizationId: serviceAgentOrganizationId,
            serviceApiURL: serviceAgentAPI,
            serviceUISettings: ServiceUISettings()
        )
    }
}
```

### Step 2: Initialize the Client with Service Agent Mode

```swift
// In PlantCareAgentforceClient.swift
import AgentforceSDK
import AgentforceService

private func setupClient() {
    // Create theme manager
    let themeManager = settings.createThemeManager()
    
    // Create custom view provider
    let viewProvider = CustomPlantViewProvider()
    
    // Get Service Agent configuration
    guard let serviceAgentConfig = settings.createServiceAgentDeploymentConfig() else {
        return  // Service Agent not configured
    }

    // Service Agent Mode
    let mode: AgentforceMode = .serviceAgent(serviceAgentConfig)
    
    // Initialize client
    agentforceClient = AgentforceClient(
        credentialProvider: credentialProvider,
        mode: mode,
        viewProvider: viewProvider,
        themeManager: themeManager
    )
}
```

### Step 3: Start a Conversation with Service Agent

```swift
// Start conversation using ES Developer Name
let conversation = agentforceClient.startAgentforceConversation(
    forESDeveloperName: serviceAgentConfig.esDeveloperName
)

currentConversation = conversation
```

### Step 4: Create UI Components

```swift
// Create Chat View
let chatView = try client.createAgentforceChatView(
    conversation: conversation,
    delegate: delegate,
    showTopBar: true,
    onContainerClose: { /* handle close */ }
)

// Create Launcher (iOS 26+)
if #available(iOS 26.0, *) {
    let launcher = client.createAgentforceLauncher(
        chatView: chatView,
        launchChatView: { /* present chat */ }
    )
}
```

### Step 5: Send Messages

```swift
// Text message
await conversation.sendUtterance(
    utterance: "Why are my leaves turning yellow?",
    attachment: nil
)

// With image attachment
let attachment = AgentforceAttachment(
    name: "plant.jpg",
    attachmentType: .Image(imageData),
    mimeType: "image/jpeg"
)

await conversation.sendUtterance(
    utterance: "What plant is this?",
    attachment: attachment
)
```

## 🎨 Customization

### Theme Customization

The app includes an advanced theme system with customizable color tokens and presets:

```swift
// CustomizableThemeManager with mode support
class CustomizableThemeManager: AgentforceThemeManaging {
    private let themeMode: AgentforceThemeMode
    private let customColors: CustomizableColors
    
    init(themeMode: AgentforceThemeMode = .system, 
         customColors: CustomizableColors = CustomizableColors()) {
        self.themeMode = themeMode
        self.customColors = customColors
    }
    
    var colors: CustomizableColors {
        return customColors.forScheme(effectiveColorScheme)
    }
}

// Color tokens for customization
struct ColorToken: Identifiable {
    let id = UUID()
    let name: String
    let lightColor: Color
    let darkColor: Color
    let category: TokenCategory
    
    enum TokenCategory: String, CaseIterable {
        case brand = "Brand"
        case surface = "Surfaces"
        case text = "Text"
        case ui = "UI Elements"
    }
}
```

### Built-in Theme Presets

The app includes several pre-configured themes:

```swift
struct ThemePresets {
    static let plantCare = CustomizableColors(/* leafy green theme */)
    static let ocean = CustomizableColors(/* blue ocean theme */)
    static let sunset = CustomizableColors(/* warm sunset theme */)
    static let forest = CustomizableColors(/* deep forest theme */)
    static let lavender = CustomizableColors(/* purple lavender theme */)
}
```

### Custom View Provider

Demonstrate custom view implementations:

```swift
class CustomPlantViewProvider: AgentforceViewProviding {
    func viewFor(content: AgentforceViewContent) -> AnyView? {
        // Return custom views for specific content types
        switch content.type {
        case "plant_card":
            return AnyView(CustomPlantCardView(data: content.data))
        default:
            return nil  // Use default SDK view
        }
    }
}
```

## 🧪 Testing

### Current Test Structure

```
PlantCareCompanionSampleAppTests/
└── PlantCareCompanionSampleAppTests.swift

PlantCareCompanionSampleAppUITests/
├── PlantCareCompanionSampleAppUITests.swift
└── PlantCareCompanionSampleAppUITestsLaunchTests.swift
```

### Running Tests

```bash
# Unit tests
xcodebuild test -scheme PlantCareCompanionSampleApp -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme PlantCareCompanionSampleApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:PlantCareCompanionSampleAppUITests
```

## 📖 Key Learnings for Developers

### 1. **Service Agent Mode Setup**
- Configure Service Agent settings before initializing the client
- Use `ServiceAgentConfiguration` for Service Agent deployment
- Start conversations with `forESDeveloperName:` instead of agent ID
- Validate Service Agent configuration completeness before client initialization

### 2. **Settings Management**
- Use `@Observable` for reactive settings that update the UI automatically
- Persist settings with UserDefaults for user convenience
- Provide UI for easy Service Agent configuration without code changes
- Check `isServiceAgentConfigured` before attempting to use the client

### 3. **iOS 26 Launcher Integration**
- Check iOS version availability with `#available(iOS 26.0, *)`
- Create launcher only after chat view is initialized
- Use `.tabViewBottomAccessory` for proper launcher placement
- Provide fallback UI for pre-iOS 26 devices

### 4. **Theme Customization**
- Support light, dark, and system theme modes
- Use color tokens for consistent theming across the app
- Provide theme presets for quick customization
- Apply `preferredColorScheme` to respect user settings

### 5. **Error Handling & User Feedback**
- Create domain-specific error types with localized descriptions
- Show Service Agent configuration status prominently in the UI
- Provide clear guidance when configuration is incomplete
- Use alerts and inline messages for error communication

### 6. **Architecture Best Practices**
- Use CompositionRoot pattern for dependency injection
- Separate concerns with MVVM architecture
- Create wrapper classes for SDK clients (PlantCareAgentforceClient)
- Use factory methods for view model creation

## 🐛 Troubleshooting

### Common Issues

**Issue**: Service Agent Configuration not recognized
```swift
// Solution: Verify all three Service Agent fields are filled
// Check in Settings: Service API URL, Organization ID, Developer Name
// The app shows configuration status on the home screen

// Programmatically check:
if settings.isServiceAgentConfigured {
    // OK to proceed
} else {
    // Show configuration prompt
}
```

**Issue**: Launcher not appearing (iOS 26+)
```swift
// Solution: Ensure chat view is created before launcher
if currentChatView == nil {
    _ = try createChatView(onClose: onClose)
}

guard let chatView = currentChatView else {
    return nil
}

return agentforceClient?.createAgentforceLauncher(
    chatView: chatView,
    launchChatView: launchChatView
)
```

**Issue**: Theme not updating after changing mode
```swift
// Solution: Re-create the theme manager when mode changes
func createThemeManager() -> AgentforceThemeManager {
    CustomizableThemeManager(themeMode: themeMode)
}

// Apply preferredColorScheme to views
.preferredColorScheme(preferredColorScheme)
```

**Issue**: Conversation fails to start
```swift
// Solution: Check credential provider and Service Agent config
guard let serviceAgentConfig = settings.createServiceAgentDeploymentConfig() else {
    throw PlantCareError.serviceAgentNotConfigured
}

// Verify credential provider returns valid credentials
let credentials = try await credentialProvider.getAccessToken()
```

**Issue**: Camera not available on simulator
```swift
// Solution: Multi-modal input requires a real device
// For testing on simulator, use image picker instead:
#if targetEnvironment(simulator)
// Use image picker
#else
// Use camera
#endif
```

## 🤝 Contributing

This is a sample application for demonstration purposes. If you find issues or have suggestions:

1. Check the [AgentforceSDK ReadMe](../README.md)
2. Check the [AgentforceSDK contribution guide](../CONTRIBUTING.md)
3. Open an issue or pull request with detailed information

## 📄 License

This sample application is provided under the BSD-3-Clause License. See LICENSE file for details.

## 🔗 Resources

- **AgentforceSDK Documentation**
  - [Main README](../README.md)
- **Salesforce Resources**
  - [Salesforce Developer Guide](https://developer.salesforce.com)
  - [Agentforce Documentation](https://developer.salesforce.com/docs/einstein/genai)
  - [Service Agent Setup](https://developer.salesforce.com)
- **iOS Development**
  - [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
  - [Swift Concurrency Guide](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
  - [Observable Macro](https://developer.apple.com/documentation/observation)

## 🙋 Support

For questions about:
- **The Sample App**: Open an issue with detailed reproduction steps
- **AgentforceSDK**: Check the [README.md](../AgentforceSDK/README.md)
- **Service Configuration**: Review your Service Agent deployment settings
- **iOS 26 Features**: Ensure you're using the correct SDK version and target
- **Salesforce Agentforce**: Contact Salesforce support or your account team

---

**Built with ❤️ to demonstrate AgentforceSDK integration patterns**

