// Template: AppCredentialProvider for Salesforce Mobile SDK / OAuth
//
// The skill should write this file as `AppCredentialProvider.swift`.
// Replace the body of `getAuthCredentials()` with whatever pulls the
// current OAuth token, org ID, and user ID from your app's auth state.
//
// If the consumer uses Salesforce Mobile SDK, swap the placeholders
// for `UserAccountManager.shared.currentUserAccount?.credentials.accessToken`
// (and `.organizationId` / `.userId`).

import Foundation
import AgentforceService

/// Supplies OAuth credentials to the Agentforce SDK on every request.
///
/// `getAuthCredentials()` is invoked for each authenticated SDK call, so
/// always return the *current* token — do not cache the value at init.
final class AppCredentialProvider: AgentforceAuthCredentialProviding {

    func getAuthCredentials() -> AgentforceAuthCredentials {
        // TODO: Replace with your real auth source. Example for Salesforce Mobile SDK:
        //
        //   guard let account = UserAccountManager.shared.currentUserAccount else {
        //       return .OAuth(authToken: "", orgId: "", userId: "")
        //   }
        //   return .OAuth(
        //       authToken: account.credentials.accessToken ?? "",
        //       orgId: account.credentials.organizationId ?? "",
        //       userId: account.credentials.userId ?? ""
        //   )
        return .OAuth(
            authToken: "{{ACCESS_TOKEN_SOURCE}}",
            orgId: "{{ORG_ID}}",
            userId: "{{USER_ID}}"
        )
    }
}
