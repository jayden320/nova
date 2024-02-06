# Nova

Language: English | [中文](README-ZH.md)

Nova is a performance monitoring SDK built into the App. You can monitor whether issues appear in the app in real time. Mainly includes the following functions:

## Development and testing phase:
* Issue reminder: An issue notification pops up in the App, check the issue log.
    * Memory leak
    * ANR
    * Child thread updates UI
* Floating window: display cpu / memory / fps indicators

## Production phase:
* Issue callback: Notify App through delegate callback. App can report these issues to the backend.

# How to use
Nova is divided into Core layer, UI layer and multiple independent plug-ins.
Nova Core is the core part of Nova, managing the life cycle of Nova and plug-ins, as well as the distribution of issue events.
Nova UI is primarily a debugging tool. Responsible for the Issue notification pop-up window and the rendering of the Nova page.
It is recommended to integrate Nova Core in all builds and Nova UI in internal test builds.

## Podfile
Nova Core is the default subspec of Nova. As long as the plug-in is connected in the Podfile, Nova Core will be connected by default.
```Ruby
   pod 'NovaMetrics', subspecs: [
      'AnrMonitorPlugin',
      'PageMonitorPlugin',
      'MemoryLeaksPlugin',
      'UIThreadMonitorPlugin',
   ]
```
 
NovaUI is a debugging tool and is recommended to be integrated only in test builds. Can be configured via configurations in Podfile.
```Ruby
   pod 'NovaUI', configurations: %w[Debug]
```
## Launch Nova

First, you need to create a plug-in instance, then call Nova's launch interface and pass in the plug-in array.
```Swift
public class Nova {
    /// Launch Nova with plugins.
    /// - Parameter plugins: Plugins must be subclasses of NovaPlugin.
    public func launch(plugins: [NovaPlugin])
}
```
 
Example:
```Swift
let plugins = [
    AnrMonitorPlugin(),
    MemoryLeakMonitorPlugin(),
    UIThreadMonitorPlugin(),
]
Nova.shared.launch(plugins: plugins)

for plugin in plugins {
    plugin.start()
}
```
## Nova Log

Nova does not output logs on the console by default. If you need to obtain the logs inside Nova, the App first needs to set Nova's logDelegate property, and then implement the NovaLogDelegate protocol.
```Swift
public class Nova {
    /// Nova does not output logs by default. If you need to get the log information in the Nova, you need to set the logDelegate and implement the corresponding method.
    public weak var logDelegate: NovaLogDelegate?
}
```
 
Example:
```Swift
Nova.shared.logDelegate = self
 
extension NovaManager: NovaLogDelegate {
    public func shouldLog(level: NovaLogLevel) -> Bool {
        level == .warn || level == .error
    }
 
    public func novaLog(level: NovaLogLevel, module: String, file: String, function: String, line: Int, message: String) {
        // print log
    }
}
```
## Monitor Issue
The App layer can monitor whether the plug-in generates an Issue, and then determines whether to report the Issue.
```Swift
public class Nova {
    /// Add Nova listener. For example, when an issue occurs, the `onReport` callback will be called
    /// - Parameter listener: listening instance
    public func addListener(_ listener: NovaDelegate)
}
```
 
Example:
```Swift
Nova.shared.addListener(self)
 
extension NovaManager: NovaDelegate {
    public func onReport(_ issue: NovaIssue) {
        reporter.report(issue: issue)
    }
}
```
## Launch NovaUI
```Swift
public struct NovaUIConfig {
    /// If the log is enabled, when an issue occurs, SDK will write the issue log to the local file.
    public var isIssueLogEnabled: Bool
 
    /// If issue notification is enabled, when an issue occurs, an issue notification will pop up in the App.
    public var isIssueNotificationEnabled: Bool
 
    /// If the floating window is enabled, the floating window related to performance indicators (cpu, memory, FPS) will be displayed in the App.
    public var isFloatingWindowEnabled: Bool
 
    public init(isIssueLogEnabled: Bool, isIssueNotificationEnabled: Bool, isFloatingWindowEnabled: Bool)
}
 
public class NovaUI {
    public func launch(defaultConfig: NovaUIConfig)
}
```
 
Example:
```Swift
let uiConfig = NovaUIConfig(isIssueLogEnabled: true, isIssueNotificationEnabled: true, isFloatingWindowEnabled: true)
NovaUI.shared.launch(defaultConfig: uiConfig)
```

## Floating window
Real-time display of current App performance indicators, including:
* Memory usage
* CPU usage
* Frame rate information

The default switch of floating windows can be controlled through the `isFloatingWindowEnabled` property in NovaUIConfig.
 
## Plug-in introduction
| Plug-in | Description | Third-party dependencies |
|----------------------|--------------------------------------------|------------|
| AnrMonitorPlugin | Monitor the running status of the main thread, if the main thread is blocked beyond the threshold | |
| PageMonitorPlugin | Page creation time-consuming statistics, pure statistics plug-in, will not report issues | VCProfiler |
| MemoryLeakMonitorPlugin | Observe the creation and recycling of objects to determine whether there is a memory leak | MLeaksFinder |
| UIThreadMonitorPlugin | Monitor whether there is an operation to update the UI in the child thread | |
