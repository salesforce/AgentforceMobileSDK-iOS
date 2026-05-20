// Template: AppCredentialProvider for Org JWT
//
// The skill should write this file as `AppCredentialProvider.swift`.
// `getAuthCredentials()` must return the *current* JWT every time it's
// called — JWTs expire, and the SDK does not refresh them.

import Foundation
import AgentforceService

/// Supplies a Salesforce-signed Org JWT to the Agentforce SDK on every request.
final class AppCredentialProvider: AgentforceAuthCredentialProviding {

    /// Closure that returns the latest JWT. Call out to your backend, keychain,
    /// or whatever stores the token — do not cache the value here.
    private let jwtSource: () -> String

    init(jwtSource: @escaping () -> String) {
        self.jwtSource = jwtSource
    }

    func getAuthCredentials() -> AgentforceAuthCredentials {
        return .OrgJWT(orgJWT: jwtSource())
    }
}
