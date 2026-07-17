// Wrapper target source. Re-exports the AgentforceSDK binary so
// consumers who `import AgentforceSDK` (the binary module name) get
// every public symbol, while SwiftPM links the binary plus the
// transitive SPM dependencies declared on this target.

@_exported import AgentforceSDK
