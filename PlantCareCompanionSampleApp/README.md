# Plant Care Companion - Voice-Enabled Service Agent Demo

A voice-enabled iOS demo app built with the [Agentforce Mobile SDK](https://github.com/salesforce/AgentforceMobileSDK-iOS). This app demonstrates how to integrate a Salesforce Service Agent with voice capabilities into a SwiftUI application, using the Plant Care Companion theme as a sample use case.

![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-BSD--3-green)

## Quick Start

### Prerequisites

- **Xcode 16.0+**
- **iOS 18.0+** deployment target
- **CocoaPods** installed (`sudo gem install cocoapods`)
- A **Salesforce org** with a Service Agent configured for voice. See the setup guides below if you haven't done this yet:
  - [Enable Voice for Service Agents (Salesforce Help)](https://help.salesforce.com/s/articleView?id=ai.service_agent_voice.htm&type=5)
  - [Agentforce Mobile SDK – Voice Integration (Developer Guide)](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-sdk-ios-voice.html)

### Step 1: Clone the Repository

```bash
git clone -b tdx2026 https://github.com/salesforce/AgentforceMobileSDK-iOS.git
cd AgentforceMobileSDK-iOS/PlantCareCompanionSampleApp
```

### Step 2: Install Dependencies with CocoaPods

```bash
pod install
```

This installs the Agentforce Mobile SDK and its dependencies (LiveKit for voice, Messaging-InApp-Core, etc.) as defined in the `Podfile`.

> **Important:** After `pod install`, always open the **workspace** (`.xcworkspace`), not the project (`.xcodeproj`).

### Step 3: Configure Your Service Agent

Open `PlantCareCompanionSampleApp/Models/PlantCareSettings.swift` and set the two required values:

```swift
// Your Salesforce My Domain URL (e.g., "https://mycompany.my.salesforce.com")
var forceConfigEndpoint = "<your-mydomain-url>"

// Your agent ID — see: https://github.com/salesforce/AgentforceMobileSDK-iOS?tab=readme-ov-file#before-you-begin
var agentId = "<your-agent-id>"
```

| Field | Description | Example |
|-------|-------------|---------|
| `forceConfigEndpoint` | Your Salesforce org's My Domain URL | `https://mycompany.my.salesforce.com` |
| `agentId` | The ID of your Service Agent deployment | `0Xx<etc>` |

To find your agent ID, follow the instructions in the [Before You Begin](https://github.com/salesforce/AgentforceMobileSDK-iOS?tab=readme-ov-file#before-you-begin) section of the SDK README.

### Step 4: Build and Run

```bash
open PlantCareCompanionSampleApp.xcworkspace
```

Select your target device or simulator and press **Cmd+R** to build and run.

## What This App Demonstrates

- **Voice-enabled Service Agent** — Real-time voice conversations with an Agentforce Service Agent
- **Text chat with multi-modal input** — Send text messages and image attachments
- **Custom theming** — Light, dark, and system theme modes with customizable color tokens
- **iOS 26 Launcher** — Tab bar accessory with AgentforceLauncher integration
- **Clean architecture** — CompositionRoot dependency injection, MVVM, and provider patterns

## Project Structure

```
PlantCareCompanionSampleApp/
├── Models/
│   ├── PlantCareError.swift              # Error types and user-friendly messages
│   └── PlantCareSettings.swift           # forceConfigEndpoint and agentId config
├── SDKIntegration/
│   ├── PlantCareAgentforceClient.swift   # Main SDK wrapper with Service Agent setup
│   ├── PlantCareCredentialProvider.swift  # Authentication provider
│   ├── PlantCareDelegate.swift           # UI delegate and analytics handler
│   ├── PlantCareThemeManager.swift       # Base theme configuration
│   └── CustomPlantViewProvider.swift     # Custom view provider example
├── Features/
│   ├── Home/                             # Home screen with agent status
│   └── Chat/                             # Chat interface and state management
├── Theming/                              # Color tokens, presets, and theme manager
├── CompositionRoot.swift                 # Dependency injection container
├── ContentView.swift                     # Main tab navigation with launcher
├── SettingsView.swift                    # Settings configuration UI
└── PlantCareCompanionSampleAppApp.swift  # App entry point
```

## Troubleshooting

**Pod install fails:** Make sure you have CocoaPods installed and up to date. Run `sudo gem install cocoapods` then `pod install --repo-update`.

**Build fails after pod install:** Ensure you opened the `.xcworkspace` file, not the `.xcodeproj`.

**Agent doesn't connect:** Verify that `forceConfigEndpoint` and `agentId` in `PlantCareSettings.swift` are correct and that your Salesforce org has a Service Agent configured with voice enabled.

**Voice not working:** Confirm you've followed the [voice setup guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-sdk-ios-voice.html) and that your Service Agent has voice enabled in your Salesforce org ([instructions](https://help.salesforce.com/s/articleView?id=ai.service_agent_voice.htm&type=5)). On a physical device, ensure microphone permissions are granted.

## Resources

- [Agentforce Mobile SDK – iOS](https://github.com/salesforce/AgentforceMobileSDK-iOS)
- [Voice Integration Guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-sdk-ios-voice.html)
- [Enable Voice for Service Agents](https://help.salesforce.com/s/articleView?id=ai.service_agent_voice.htm&type=5)
- [Agentforce Developer Documentation](https://developer.salesforce.com/docs/einstein/genai)

## License

This sample application is provided under the BSD-3-Clause License. See the LICENSE file for details.
