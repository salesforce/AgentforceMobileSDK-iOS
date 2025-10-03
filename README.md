# Agentforce Mobile SDK - Integration Guide

> **Note**: This documentation reflects the latest SDK version with significant API updates. If you're migrating from an earlier version, please review the changes carefully.

## What's New

### Enhanced User Interface
- **Mobile-Optimized Experience**: Completely redesigned interface with native iOS design patterns for intuitive, responsive interactions
- **Advanced Theming**: Comprehensive theme system supporting custom colors, typography, and component styling to match your brand identity
- **Custom Component Overrides**: Native view provider system allowing complete customization of messaging UI components

### Enhanced Chat V2 with Service Agent Support
- **Service Agent Integration**: Full support for mobile service agent configurations through the streamlined `.serviceAgent` mode
- **Human Agent Escalation**: Seamless escalation to human agents with comprehensive messaging component support including rich links, surveys, carousels, and interactive elements
- **Omni-Channel Excellence**: Built-in support for omni-channel routing and omni-supervisor capabilities for enterprise-grade customer service

### Configuration Changes
- **New initialization pattern**: `AgentforceClient` now uses `AgentforceMode` enum (`.fullConfig`, `.serviceAgent`, `.employeeAgent`)
- **Simplified configurations**: `ServiceAgentConfiguration` and `EmployeeAgentConfiguration` for streamlined setup
- **Service agent support**: New methods for Einstein Service agents using `esDeveloperName`

### New Components
- **Launcher**: `AgentforceLauncher` floating action button for quick access
- **Conversation Management**: New `endConversation()`, `closeConversation()`, and `downloadTranscript()` methods

### API Updates
- `AgentforceAuthCredentialProviding` now returns `AgentforceAuthCredentials` (from AgentforceService)
- New `showTopBar` parameter in `createAgentforceChatView`

## Getting Started with Agentforce

The Agentforce Mobile SDK empowers you to integrate Salesforce's feature-rich, trusted AI platform directly into your native iOS and Android mobile applications. By leveraging the Agentforce Mobile SDK, you can deliver cutting-edge, intelligent, and conversational AI experiences to your mobile users, enhancing engagement and providing seamless access to information and actions.

### What is Agentforce?
Agentforce is Salesforce's platform for building and deploying trusted AI agents. These agents can understand user requests, access relevant data, perform actions across Salesforce and external systems, and generate helpful, conversational responses. The Agentforce Mobile SDK acts as the bridge, allowing your mobile app to communicate directly with these sophisticated agents, bringing the power of generative AI and automated workflows to your users' fingertips.

### Why Use the Agentforce Mobile SDK?
Integrating the Agentforce Mobile SDK into your app offers several key advantages. It allows you to deliver advanced AI experiences that go beyond simple chatbots, providing users with truly agentic capabilities for complex task completion, personalized interactions, and access to generative AI features within your app's context.

The SDK offers flexible integration options to suit your needs:

* **Full UI Experience:** Get up and running quickly by using the SDK's pre-built, customizable chat interface. This provides a rich, out-of-the-box conversational experience supporting text, voice, and multimodal inputs with minimal coding effort.  
* **Headless Integration:** For ultimate control, use the headless SDK to power your own custom user interface or to drive automated, agent-led processes in the background. You manage the conversational state and UI, while Agentforce handles the complex AI logic. 

We suggest starting with the Full UI Experience unless you need more granular control over the interface.

### **Core Features**

* **Networking:** A robust networking layer for handling both communication with the Agentforce platform and streaming responses.  
* **Conversational Intelligence:** Sophisticated Natural Language Understanding (NLU) to process user requests via text or voice.  
* **Salesforce Actions:** Execute actions within Salesforce, such as creating records, updating fields, and running Apex classes, directly from the conversation.  
* **Customizable UI:** When using the Full UI experience, you can customize the appearance of the chat interface to match your app's branding.  
* **Extensible Service Protocols:** The SDK defines a set of protocols for core services like navigation, caching, and logging, which you implement using your app's native infrastructure.

## **Before You Begin**

Before you begin integrating the Agentforce Mobile SDK,  you must first configure an agent within your Salesforce organization.

1. **Create and Configure an Agent:** You will need to build and configure an agent using the tools available in your Salesforce org. This includes defining its capabilities, persona, and connecting it to any necessary Salesforce data or actions.  
2. **Obtain Agent and Org IDs:** Once configured, you will need to retrieve the **Agent ID** and the **Salesforce Org ID**. These unique identifiers are required to initialize the SDK and route requests to the correct agent in the correct organization.   
* You can find the **Agent ID** in the URL of the Agent Details page. When you select your agent from Setup, use the 18-character ID at the end of the URL. For example, when viewing this URL, https://mydomain.salesforce.com/lightning/setup/EinsteinCopilot/0XxSB000000IPCr0AO/edit, the agent ID is 0XxSB000000IPCr0AO.  
* You can find the **Org ID** from the Company Information page in Setup. 

## iOS Integration Guidelines
This guide provides the steps to integrate the Agentforce Mobile SDK into your native iOS application.

### **Prerequisites**

* **iOS:** Version 17.0 or later  
* **Xcode:** Version 16.0 or later  
* **Swift:** Version 5.0 or later  
* An existing iOS project configured with [CocoaPods](https://cocoapods.org/).

### Install Dependencies

To integrate the SDK into your project, you'll need to manage a set of dependencies through Cocoapods. 

#### Using CocoaPods
Add the following lines to your project's Podfile. The Agentforce SDK podspec will pull in additional dependencies as needed.

At the top of your `Podfile`, add the Salesforce Mobile iOS Spec Repo above the CocoaPods trunk repo. Make sure to add the CocoaPods CDN if you use any other CocoaPods dependencies.

```ruby
source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
source 'https://github.com/livekit/podspecs.git'
source 'https://cdn.cocoapods.org/'
```

Then, in your target, add:

```ruby
pod 'AgentforceSDK'
pod 'Messaging-InApp-Core', '1.9.3-Experimental' #AgentforceSDK uses a pre-release version of this for now
```

At the bottom of your podfile where you set up your post installer, configure it as shown:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

After adding the pods, run `pod install` from your project's root directory. If CocoaPods is unable to locate the specs, try `pod install --repo-update`.

#### Dependencies

The AgentforceSDK includes the following key dependencies:

-   [AgentforceMobileService-iOS](https://github.com/forcedotcom/AgentforceMobileService-iOS): The API layer for Agentforce.
-   [SalesforceNetwork](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): An interface for consuming applications to provide a networking layer to Agentforce Mobile SDK.
-   [SalesforceNavigation](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): An interface for consuming applications to handle navigation events occurring within Agentforce Mobile SDK views.
-   [SalesforceUser](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): A designated way to provide user information to Agentforce Mobile SDK.
-   [SalesforceLogging](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS): An interface for consuming applications to handle logging from within Agentforce Mobile SDK.
-   [Swift-Markdown-UI](https://github.com/gonzalezreal/swift-markdown-ui): A rendering library for GitHub Flavored Markdown.

### Implement Core Service Protocols
The Agentforce Mobile SDK is designed for flexibility and delegates several core responsibilities to the host application. This is achieved through a set of protocols that your application must implement. This approach allows the SDK to remain lean and lets you use your existing application architecture for handling common tasks.

You will need to create concrete implementations for the following:

**AgentforceSDK Interfaces:**

* **AgentforceAuthCredentialProviding:** Supplies the SDK with the authentication token (e.g., OAuth 2.0 access token) required to communicate securely with Salesforce APIs.
* **AgentforceInstrumentation:** A handler for the SDK to emit instrumentation and telemetry data into your app's analytics system.

**Salesforce Mobile Interfaces:**

These are described in more detail in [Salesforce Mobile Interfaces](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS)

* **SalesforceNetwork.Network:** Provides the SDK with the ability to make authenticated network calls to Salesforce. Your implementation will handle the underlying networking logic, leveraging your app's existing network stack, and will be responsible for attaching the necessary authentication tokens to each request.
* **SalesforceNavigation.Navigation:** Handles navigation requests from the agent. For example, if the agent provides a link to a specific record, this interface allows your app to intercept that request and navigate the user to the appropriate screen within your native application.
* **SalesforceLogging.Logger:** Allows the SDK to pipe its internal logs into your application's logging system for easier debugging and monitoring.

By implementing these interfaces, you provide the "scaffolding" that the Agentforce SDK builds upon, ensuring seamless integration with your app's existing ecosystem.

**Example `AgentforceAuthCredentialProviding` Implementation:**
```swift
import Foundation
import AgentforceService

// An example implementation that retrieves auth details from a hypothetical SessionManager.
class MyAppCredentialProvider: AgentforceAuthCredentialProviding {

    public func getAuthCredentials() -> AgentforceAuthCredentials {
        // If using OAuth
        return .OAuth(authToken: getCurrentAuthToken(), orgId: orgId, userId: userId)

        // If using OrgJWTs
        return .OrgJWT(orgJWT: getOrgJWT())
    }
}
```

### Create an `AgentforceConfiguration` Instance

The SDK supports multiple configuration modes to simplify different integration scenarios:

#### Option 1: Full Configuration (Most Control)
For complete customization control over all SDK features:

```swift
import AgentforceSDK

let agentforceConfiguration = AgentforceConfiguration(
    user: currentUser,
    forceConfigEndpoint: "YOUR_INSTANCE_URL", // e.g. "https://your-domain.my.salesforce.com"
    dataProvider: dataProvider, // Optional
    imageProvider: imageProvider, // Optional
    instrumentationHandler: instrumentationHandler, // Optional
    agentforceFeatureFlagSettings: featureFlags,
    salesforceNetwork: networkManager,
    salesforceNavigation: navigationHandler,
    salesforceLogger: logger, // Optional
    ttsVoiceProvider: ttsProvider, // Optional
    speechRecognizer: speechRecognizer // Optional
)
```

#### Option 2: Service Agent Configuration (Simplified)
For service agent integrations:

```swift
import AgentforceSDK

let serviceConfig = ServiceAgentConfiguration(
    esDeveloperName: "YOUR_ES_DEVELOPER_NAME",
    organizationId: "YOUR_ORG_ID",
    serviceApiURL: "YOUR_SERVICE_API_URL",
    serviceUISettings: ServiceUISettings(
        downloadTranscript: true,
        endConversation: true
    )
)
```

#### Option 3: Employee Agent Configuration (Simplified)
For internal employee agent integrations:

```swift
import AgentforceSDK

let employeeConfig = EmployeeAgentConfiguration(
    user: currentUser,
    forceConfigEndpoint: "YOUR_INSTANCE_URL"
)
```

For more advanced configurations, you can provide implementations for the following protocols:

-   `dataProvider`: Provide custom data to the agent
-   `imageProvider`: Provide custom images to the UI
-   `agentforceCopier`: Handle copy to clipboard functionality
-   `instrumentationHandler`: Receive detailed instrumentation events
-   `salesforceNavigation`: Handle navigation events
-   `salesforceLogger`: Provide a custom logger
-   `ttsVoiceProvider`: Provide a custom text-to-speech engine
-   `speechRecognizer`: Provide a custom speech-to-text engine

### Initialize the SDK and Build the View
You can initialize the SDK in one of two ways, depending on whether you want to use the pre-built UI or a headless implementation.

#### Option A: Full UI Experience
This approach is best if you want a complete, out-of-the-box chat interface. The `AgentforceClient` manages the session and provides a SwiftUI View that you can present in your app.

##### Instantiate `AgentforceClient`
Create and retain an instance of `AgentforceClient`. The initialization depends on which configuration mode you're using:

```swift
import AgentforceSDK

class AgentforceManager: ObservableObject {
    let agentforceClient: AgentforceClient

    init() {
        let credentialProvider = MyAppCredentialProvider()
        
        // Option 1: Using Full Configuration
        let config = AgentforceConfiguration(...)
        self.agentforceClient = AgentforceClient(
            credentialProvider: credentialProvider,
            mode: .fullConfig(config),
            viewProvider: customViewProvider, // Optional
            themeManager: customThemeManager // Optional
        )
        
        // Option 2: Using Service Agent Configuration
        let serviceConfig = ServiceAgentConfiguration(...)
        self.agentforceClient = AgentforceClient(
            credentialProvider: credentialProvider,
            mode: .serviceAgent(serviceConfig)
        )
        
        // Option 3: Using Employee Agent Configuration
        let employeeConfig = EmployeeAgentConfiguration(...)
        self.agentforceClient = AgentforceClient(
            credentialProvider: credentialProvider,
            mode: .employeeAgent(employeeConfig)
        )
    }
}
```

Note: The `AgentforceClient` must be retained for the duration of the conversation. If it is deallocated, the session will be lost. Instantiate it in an object with an appropriate lifecycle for your needs.

##### Starting a Conversation

Once you have initialized the `AgentforceClient`, you can start a conversation with an agent. The method to use depends on your agent type:

```swift
// For regular agents (using agent ID)
let conversation = agentforceClient.startAgentforceConversation(
    forAgentId: "YOUR_AGENT_ID", 
    sessionId: nil // Optional: provide a session ID to resume a conversation
)

// For service agents (using Einstein Service developer name)
let conversation = agentforceClient.startAgentforceConversation(
    forESDeveloperName: "YOUR_ES_DEVELOPER_NAME"
)
```

This method returns an `AgentConversation` object, which represents a single conversation with an agent.

##### Displaying the Chat UI

To display the chat UI, you can use the `createAgentforceChatView` method. This method returns a SwiftUI view that you can present to the user.

```swift
do {
    let chatView = try agentforceClient.createAgentforceChatView(
        conversation: conversation,
        delegate: self,
        showTopBar: true, // Optional: controls top bar visibility (default: true)
        onContainerClose: {
            // Handle chat view close
        }
    )
    // Present the chatView in your SwiftUI hierarchy
} catch {
    // Handle error
}
```

The `createAgentforceChatView` method takes the following parameters:

-   `conversation`: The `AgentConversation` object that you created earlier
-   `delegate`: An object that conforms to the `AgentforceUIDelegate` protocol. This delegate will receive notifications about UI events
-   `showTopBar`: Optional boolean to control the visibility of the top navigation bar (default: true)
-   `onContainerClose`: A closure that will be called when the user closes the chat view

## Basic Use Cases

### Send Messages

To send a message to the agent, you can use the `sendUtterance` method on the `AgentConversation` object.

```swift
await conversation.sendUtterance(utterance: "Hello, world!", attachment: nil)
```

### Receive Messages

To receive messages from the agent, you can subscribe to the `messages` publisher on the `AgentConversation` object.

```swift
conversation.messages
    .sink { messages in
        // Handle new messages
    }
    .store(in: &cancellables)
```

### Handle UI Events

To handle UI events, you can implement the `AgentforceUIDelegate` protocol. This protocol has the following methods:

-   `modifyUtteranceBeforeSending(_:)`: This method is called before an utterance is sent to the agent. It allows you to modify the utterance before it is sent.
-   `didSendUtterance(_:)`: This method is called after an utterance has been sent to the agent.
-   `userDidSwitchAgents(newConversation:)`: This method is called when the user switches to a different agent.
-   `userInitiatedVoice(for:)`: This method is called when the user initiates a voice interaction. This is not yet enabled.

```swift
extension YourViewController: AgentforceUIDelegate {
    func modifyUtteranceBeforeSending(_ utterance: AgentforceUtterance) async -> AgentforceUtterance {
        // Modify the utterance if needed
        return utterance
    }

    func didSendUtterance(_ utterance: AgentforceUtterance) {
        // Handle sent utterance
    }

    func userDidSwitchAgents(newConversation: AgentConversation) {
        // Handle agent switch
    }
    
    func userInitiatedVoice(for conversation: AgentConversation) {
        // Handle voice interaction start
    }
}
```

### Manage Conversation Lifecycle

The SDK provides several methods to manage the conversation lifecycle:

#### End Conversation
End the conversation while keeping it resumable:

```swift
do {
    try await conversation.endConversation()
    // Conversation is ended but can be resumed by sending a new message
} catch {
    // Handle error
}
```

#### Close Conversation
Completely close the conversation (not resumable):

```swift
do {
    try await conversation.closeConversation()
    // Conversation is closed and cannot be resumed
} catch {
    // Handle error
}
```

#### Download Transcript
Generate and download a PDF transcript (Service Agents only):

```swift
do {
    let transcript = try await conversation.downloadTranscript()
    // Use transcript.url to access the PDF file
} catch {
    // Handle error
}
```

#### Option B: Headless Integration
This approach is for developers who want to build a completely custom UI or run agent interactions in the background. The AgentforceService handles the communication and state, emitting events that your app uses to update its own UI. For more details, see the [AgentforceMobileService-iOS](https://github.com/forcedotcom/AgentforceMobileService-iOS) repo.

## Advanced Topics

### Custom View Providers

The `AgentforceViewProviding` protocol allows you to provide your own custom views for the different components that are displayed in the chat interface. This is useful if you want to replace the default implementation of a component with your own.

To provide your own views, you must create a class that conforms to the `AgentforceViewProviding` protocol and implement the following methods:

-   `canHandle(type:)`: This method should return `true` if you want to provide a custom view for the given component type, and `false` otherwise.
-   `view(for:data:)`: This method should return your custom view for the given component type. The `data` parameter contains the properties for the component.

Here is an example of how you can provide a custom view for the `AF_RICH_TEXT` component:

```swift
import AgentforceSDK
import SwiftUI

class CustomViewProvider: AgentforceViewProviding {
    func canHandle(type: String) -> Bool {
        return type == "AF_RICH_TEXT"
    }

    @MainActor
    func view(for type: String, data: [String : Any]) -> AnyView {
        if type == "AF_RICH_TEXT" {
            let value = data["value"] as? String ?? ""
            return AnyView(Text(value).font(.custom("YourFont", size: 16)))
        }
        return AnyView(EmptyView())
    }
}
```

Once you have created your custom view provider, you can pass it to the `AgentforceClient` when you initialize it:

```swift
let agentforceClient = AgentforceClient(
    credentialProvider: yourCredentialProvider,
    mode: .fullConfig(agentforceConfiguration),
    viewProvider: CustomViewProvider(),
    themeManager: customThemeManager // Optional
)
```

### Instrumentation

The Agentforce SDK provides a detailed instrumentation framework for monitoring performance and usage. To receive instrumentation events, you can provide an implementation of the `AgentforceInstrumentationHandling` protocol in your `AgentforceConfiguration`.

```swift
class MyInstrumentationHandler: AgentforceInstrumentationHandling {
    func recordEvent(_ event: AgentforceInstrumentationEvent) {
        // Handle instrumentation events
        print("Instrumentation event: \(event)")
    }
}

// Include in your config
let agentforceConfiguration = AgentforceConfiguration(
    agentId: "YOUR_AGENT_ID",
    orgId: "YOUR_ORG_ID",
    forceConfigEndpoint: "YOUR_INSTANCE_URL",
    instrumentationHandler: MyInstrumentationHandler()
)
```

## Support and Resources

For additional documentation, examples, and support:

- [Salesforce Developer Documentation](https://developer.salesforce.com)
- [Agentforce Mobile Service iOS](https://github.com/forcedotcom/AgentforceMobileService-iOS)
- [Salesforce Mobile Interfaces](https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS)


## Contributing

See `CONTRIBUTING.md`

## License

This project is licensed under the terms specified in the `LICENSE.txt` file.