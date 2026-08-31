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

Use the public distribution package. Its minimum platform is iOS 17 and it contains the binary SDK plus matching transitive dependencies.

Add to `dependencies` array in `Package.swift`:

```swift
.package(
    url: "https://github.com/salesforce/AgentforceMobileSDK-iOS.git",
    from: "18.26.17"
)
```

Then add to the relevant target's dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "AgentforceSDK", package: "AgentforceMobileSDK-iOS"),
        // Optional when voice is enabled:
        // .product(name: "AgentforceVoice", package: "AgentforceMobileSDK-iOS")
    ]
)
```

For Xcode `.xcodeproj`-based SPM, do not edit `project.pbxproj` by hand. Instead, surface the steps:

1. **File → Add Package Dependencies…**
2. Paste `https://github.com/salesforce/AgentforceMobileSDK-iOS.git`
3. Pick **Up to Next Major Version** from `18.26.17` (less than `19.0.0`).
4. Add `AgentforceSDK` to the app target.
5. Add `AgentforceVoice` only if the app uses voice.

For a production app, keep the stable `18.26.17` baseline. If the user explicitly asks to preview Agentforce Mobile 262.2, pin the exact prerelease instead of using a range:

```swift
.package(
    url: "https://github.com/salesforce/AgentforceMobileSDK-iOS.git",
    exact: "18.33.14-rc1"
)
```

The 262.2 prerelease also exposes the optional `AgentforceCustomization` product. Label the prerelease non-production and do not silently migrate a stable app to it.

### SPM package-graph guardrails

- Do not add `https://github.com/forcedotcom/AgentforceMobileService-iOS` separately. `AgentforceService` is a bundled binary target and remains importable through the AgentforceSDK package.
- Do not add the same package in both `Package.swift` and the Xcode project UI.
- Resolve with `xcodebuild -resolvePackageDependencies -project <App>.xcodeproj -scheme <Scheme>` before compiling.
- If Xcode reports a stale binary artifact after a version switch, use **File → Packages → Reset Package Caches**, then **Resolve Package Versions**. Do not delete broad cache directories automatically.

## CocoaPods steps

Full `Podfile` (mirror of `PlantCareCompanionSampleApp/Podfile`):

```ruby
platform :ios, '17.0'

target_deployment_version = '17.0'

target 'YourApp' do
  source 'https://github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
  source 'https://github.com/Salesforce-Async-Messaging/podspecs.git'
  source 'https://github.com/livekit/podspecs.git'
  source 'https://cdn.cocoapods.org/'
  use_frameworks!

  pod 'AgentforceSDK'
  pod 'Messaging-InApp-Core', '> 1.10.0'
  # Optional voice support:
  # pod 'AgentforceVoice'
  # pod 'LiveKitClient'
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

The `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` flag is **required** — without it, builds can fail with module-stability errors against the pre-built `AgentforceSDK.xcframework`.

Source order matters: keep the Salesforce and Async Messaging spec sources before the CocoaPods CDN. `Messaging-InApp-Core` is explicitly listed by the current public integration guide. Add `LiveKitClient` with `AgentforceVoice`; add other individually named transitive pods only if CocoaPods reports a concrete resolution or runtime-linking failure.

Then:

```bash
pod install
# or, if specs don't resolve:
pod install --repo-update
```

## Static linking

If the consumer wants `use_frameworks! :linkage => :static`, they additionally need the `cocoapods-user-defined-build-types` plugin and per-pod `:build_type => :dynamic_framework` declarations. See the SDK's main README "Static Linking" section before scaffolding for this case.
