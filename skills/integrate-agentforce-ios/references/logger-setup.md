# Logger setup reference

The Agentforce SDK accepts any `SalesforceLogging.Logger`. Default scaffold uses an OSLog-backed implementation under the subsystem `com.salesforce.agentforce`, with one `os.Logger` per `LogLevel`.

## Why OSLog

- Free in production: no string formatting until viewed.
- Filterable in **Console.app** by subsystem and category.
- Persists in the unified system log; survives app restarts.
- No third-party dependency.

## Wire-up

The logger is passed differently depending on the chosen `AgentforceMode`:

| Mode | How the logger is passed |
|---|---|
| `.employeeAgent` | `EmployeeAgentConfiguration.withLogger(_:)` builder |
| `.serviceAgent` | `ServiceAgentConfiguration.withLogger(_:)` builder |
| `.fullConfig` | `salesforceLogger:` parameter on `AgentforceConfiguration.init` |

Example (service agent):

```swift
let config = ServiceAgentConfiguration(
    esDeveloperName: "MyAgent",
    organizationId: "00D...",
    serviceApiURL: "https://...",
    forceConfigEndPoint: "https://..."
)
.withLogger(AgentforceConsoleLogger())
```

## Viewing logs

In Console.app:
1. Select the simulator/device under **Devices** in the sidebar.
2. In the search bar: `subsystem:com.salesforce.agentforce`.
3. Optionally filter by category: `network`, `ui`, `conversation`, etc. (whichever the SDK emits).

In Terminal: `log stream --predicate 'subsystem == "com.salesforce.agentforce"'`.

## Why not `print()`

The PlantCareCompanion sample uses `print()` for brevity. That's fine for a demo but avoid it in production: `print()` only emits to Xcode's console (not the unified log), can't be filtered, and runs in release builds with full formatting cost.
