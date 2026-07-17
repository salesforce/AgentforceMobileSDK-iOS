// Wrapper target source. Re-exports the AgentforceVoice binary so
// consumers who `import AgentforceVoice` (the binary module name) get
// every public symbol, while SwiftPM links the binary plus the
// transitive SPM dependencies declared on this target.

@_exported import AgentforceVoice
