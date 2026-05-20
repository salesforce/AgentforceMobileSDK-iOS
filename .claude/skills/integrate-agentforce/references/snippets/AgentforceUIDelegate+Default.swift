// Default AgentforceUIDelegate. Hook your analytics or message-rewriting
// logic into the methods below; remove what you don't need.

import Foundation
import AgentforceSDK
import AgentforceService

@MainActor
final class AppAgentforceDelegate: AgentforceUIDelegate {

    func modifyUtteranceBeforeSending(_ utterance: AgentforceUtterance) async -> AgentforceUtterance {
        // TODO: rewrite or annotate the utterance before it leaves the device.
        return utterance
    }

    func didSendUtterance(_ utterance: AgentforceUtterance) {
        // TODO: track in analytics.
    }

    func userDidSwitchAgents(newConversation: AgentConversation) {
        // TODO: react to multi-agent handoff (e.g. update header, log event).
    }

    func userInitiatedVoice(for conversation: AgentConversation) {
        // TODO: track voice-interaction start.
    }
}
