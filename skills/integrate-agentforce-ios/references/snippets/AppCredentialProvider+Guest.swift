// Template: AppCredentialProvider for Guest URL
//
// Only use this when the agent is publicly accessible via the Agent API
// behind an Experience Cloud site, and you specifically need URL-only
// guest credentials. Most public agent integrations should use
// AgentforceMode.serviceAgent (no credential provider needed).

import Foundation
import AgentforceService

final class AppCredentialProvider: AgentforceAuthCredentialProviding {

    private let guestURL: String

    init(guestURL: String = "{{GUEST_URL}}") {
        self.guestURL = guestURL
    }

    func getAuthCredentials() -> AgentforceAuthCredentials {
        return .Guest(url: guestURL)
    }
}
