# Nova
Language: [English](README.md) | 中文

Nova 是一个植入App内的性能监控 SDK。可以实时监控 App 内是否出现 Issue。主要包括以下功能：

## 开发、测试阶段： 
* Issue 提醒：App内弹出 issue 通知，查看 issue 日志。
    * 内存泄露
    * ANR
    * 子线程更新 UI 
* 悬浮窗：显示 cpu / memory / fps 指标

## 线上： 
* Issue 回调：通过 delegate 回调告知 App。App 可以将这些 issue 上报到后端。

# 接入Nova SDK
Nova 分为 Core 层、UI 层以及多个互相独立的插件。
Nova Core 是 Nova 的核心部分，管理着 Nova 和插件的生命周期，以及 issue 事件的分发。
Nova UI 主要是调试工具。负责 Issue 的通知弹窗，以及 Nova 页面的呈现。
建议在所有 build 版本中集成 Nova Core，在内部测试版本中集成 Nova UI。

## Podfile
Nova Core 是 Nova 的 default subspec，只要在 Podfile 中接入插件，就会默认接入 Nova Core。
```Ruby
  pod 'NovaMetrics', subspecs: [
      'AnrMonitorPlugin',
      'PageMonitorPlugin',
      'MemoryLeaksPlugin',
      'UIThreadMonitorPlugin',
  ]
```
 
NovaUI 是调试工具，建议只在测试的 build 中集成。可以在 Podfile 中通过 configurations 配置。
```Ruby
  pod 'NovaUI', configurations: %w[Debug]
```
## 启动Nova

首先需要创建插件实例，然后调用 Nova 的 launch 接口，传入插件的数组。
```Swift
public class Nova {
    /// Launch Nova with plugins.
    /// - Parameter plugins: Plugins must be subclasses of NovaPlugin.
	public func launch(plugins: [NovaPlugin])
}
```
 
示例：
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
## Nova日志

Nova 默认不会在控制台输出日志。如果需要获取 Nova 内部的日志，App 首先需要设置 Nova 的 logDelegate 属性，然后实现 NovaLogDelegate 协议。
```Swift
public class Nova {
    /// Nova does not output logs by default. If you need to get the log information in the Nova, you need to set the logDelegate and implement the corresponding method.
    public weak var logDelegate: NovaLogDelegate? 
}
```
 
示例：
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
## 监听Issue
App 层可以监听插件是否产生 Issue，然后自行判断是否上报 Issue。
```Swift
public class Nova {
	/// Add Nova listener. For example, when an issue occurs, the `onReport` callback will be called
	/// - Parameter listener: listening instance
	public func addListener(_ listener: NovaDelegate)
}
```
 
示例：
```Swift
Nova.shared.addListener(self)
 
extension NovaManager: NovaDelegate {
    public func onReport(_ issue: NovaIssue) {
        reporter.report(issue: issue)
    }
}
```
## 启动 NovaUI
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
 
示例：
```Swift
let uiConfig = NovaUIConfig(isIssueLogEnabled: true, isIssueNotificationEnabled: true, isFloatingWindowEnabled: true)
NovaUI.shared.launch(defaultConfig: uiConfig)
```

## 悬浮窗
实时显示当前App的性能指标，包括：
* 内存的使用情况
* CPU使用率
* 帧率信息

悬浮窗的默认开关，可以通过 NovaUIConfig 里的 `isFloatingWindowEnabled` 属性控制。

 
## 插件介绍
| 插件 | 说明 | 三方依赖 |
|----------------------|--------------------------------------------|------------|
| AnrMonitorPlugin | 监控主线程运行情况，如果主线程被阻塞超过阈值 | |
| PageMonitorPlugin | 页面创建耗时统计，纯统计插件，不会报 issue | 基于 VCProfiler |
| MemoryLeakMonitorPlugin | 观察对象的创建、回收情况，判断是否出现内存泄露 | 基于 MLeaksFinder |
| UIThreadMonitorPlugin | 监控是否有在子线程执行更新UI的操作 | |
