# Dependency manager detection

## Decision tree

1. If `Package.swift` exists at the project root **and** declares iOS as a platform → **SPM-only project**. Edit `Package.swift`.
2. Else if `Podfile` exists → **CocoaPods project**. Edit `Podfile`.
3. Else if `*.xcodeproj` or `*.xcworkspace` exists → **Xcode project**. Could use either:
   - Check for a `Podfile` sibling (CocoaPods).
   - Check for `Package.resolved` in the `.xcodeproj` (project-level SPM dependencies via Xcode).
   - If both are absent, recommend SPM via Xcode's **File → Add Package Dependencies**.
4. If nothing matches, ask the user where the project root is and `cd` there.

When **both** SPM and CocoaPods are present, prefer SPM and surface a note that the user can remove the duplicate from one. Don't silently maintain both.

## Refusing to run inside the SDK repo

If the working directory contains `Sources/AgentforceSDKTarget/` (this SDK's own source layout), refuse and tell the user to `cd` into their consuming app. Running the skill against the SDK repo would try to add the SDK as a dependency to itself.

## SPM steps

Add to `dependencies` array in `Package.swift`:

```swift
.package(url: "https://github.com/salesforce/AgentforceMobileSDK-iOS.git", from: "15.5.1")
```

Then add to the relevant target's dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "AgentforceSDK", package: "AgentforceMobileSDK-iOS")
    ]
)
```

For Xcode `.xcodeproj`-based SPM, do not edit `project.pbxproj` by hand. Instead, surface the steps:

1. **File → Add Package Dependencies…**
2. Paste `https://github.com/salesforce/AgentforceMobileSDK-iOS.git`
3. Pick "Up to Next Major Version" from `15.5.1`
4. Add the `AgentforceSDK` library product to the app target.

## CocoaPods steps

Full `Podfile` (mirror of `PlantCareCompanionSampleApp/Podfile`):

```ruby
platform :ios, '18.0'

target_deployment_version = '18.0'

target 'YourApp' do
  source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
  source 'https://github.com/livekit/podspecs.git'
  source 'https://cdn.cocoapods.org/'
  use_frameworks!

  pod 'AgentforceSDK'
  pod 'Messaging-InApp-Core'   # AgentforceSDK uses a pre-release; pin if you must
  pod 'LiveKitClient'          # ensures CocoaPods picks the right source
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = target_deployment_version
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      if defined?(target.product_type) && target.product_type == "com.apple.product-type.framework"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
      if defined?(target.product_type) && target.product_type == "com.apple.product-type.bundle"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
```

The `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` flag is **required** — without it, builds fail with module-stability errors against the pre-built `AgentforceSDK.xcframework`.

Source order matters: the Salesforce specs source must come **before** the CocoaPods CDN.

Then:

```bash
pod install
# or, if specs don't resolve:
pod install --repo-update
```

## Static linking

If the consumer wants `use_frameworks! :linkage => :static`, they additionally need the `cocoapods-user-defined-build-types` plugin and per-pod `:build_type => :dynamic_framework` declarations. See the SDK's main README "Static Linking" section before scaffolding for this case.
