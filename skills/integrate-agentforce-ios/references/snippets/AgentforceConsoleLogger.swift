// OSLog-backed SalesforceLogging.Logger.
//
// Visible in Console.app filtered by `subsystem:com.salesforce.agentforce`,
// or via `log stream --predicate 'subsystem == "com.salesforce.agentforce"'`.

import Foundation
import OSLog
import SalesforceLogging

struct AgentforceConsoleLogger: SalesforceLogging.Logger {

    private static let subsystem = "com.salesforce.agentforce"

    private let debug = os.Logger(subsystem: subsystem, category: "debug")
    private let info = os.Logger(subsystem: subsystem, category: "info")
    private let warn = os.Logger(subsystem: subsystem, category: "warn")
    private let error = os.Logger(subsystem: subsystem, category: "error")

    func log(_ logMessage: String, level: LogLevel) {
        switch level {
        case .debug:
            debug.debug("\(logMessage, privacy: .public)")
        case .info:
            info.info("\(logMessage, privacy: .public)")
        case .warning:
            warn.warning("\(logMessage, privacy: .public)")
        case .error, .fault:
            error.error("\(logMessage, privacy: .public)")
        @unknown default:
            info.log("\(logMessage, privacy: .public)")
        }
    }
}
