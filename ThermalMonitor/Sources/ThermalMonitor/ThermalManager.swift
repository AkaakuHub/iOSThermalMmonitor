import Foundation
import Combine
import UserNotifications
import os.log

final class ThermalManager: ObservableObject {
    static let shared = ThermalManager()
    
    @Published private(set) var thermalState: ProcessInfo.ThermalState
    @Published private(set) var lastStateChange: Date = Date()
    
    private var monitoringTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "com.thermalmonitor.app", category: "ThermalManager")
    
    private init() {
        self.thermalState = ProcessInfo.processInfo.thermalState
        startMonitoring()
        requestNotificationPermission()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        stopMonitoring()
        
        monitoringTask = Task {
            let stream = AsyncStream<ProcessInfo.ThermalState> { continuation in
                let observer = NotificationCenter.default.addObserver(
                    forName: ProcessInfo.thermalStateDidChangeNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield(ProcessInfo.processInfo.thermalState)
                }
                continuation.onTermination = { @Sendable _ in
                    NotificationCenter.default.removeObserver(observer)
                }
            }
            
            for await newState in stream {
                if self.thermalState != newState {
                    let previousState = self.thermalState
                    logger.info("Thermal state changed from \(String(describing: previousState)) to \(String(describing: newState))")
                    
                    self.thermalState = newState
                    self.lastStateChange = Date()
                    
                    await sendNotificationIfNeeded(from: previousState, to: newState)
                }
            }
        }
    }
    
    private func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
    
    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge, .provisional]
                )
                logger.info("Notification permission granted: \(granted)")
            } catch {
                logger.error("通知許可エラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendNotificationIfNeeded(from previousState: ProcessInfo.ThermalState, to newState: ProcessInfo.ThermalState) async {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.interruptionLevel = .active
        
        // iOS 18の新しい通知カテゴリーを設定
        switch newState {
        case .nominal:
            if previousState != .nominal {
                content.title = "デバイス温度が正常に戻りました"
                content.body = "デバイスの温度が正常レベルに戻りました。通常の使用を再開できます。"
                content.categoryIdentifier = "THERMAL_NORMAL"
                content.interruptionLevel = .passive
            } else {
                return // 正常状態内での変化は通知しない
            }
        case .fair:
            content.title = "デバイス温度が上昇しています"
            content.body = "デバイスが少し温まっています。重い処理は控えめにしてください。"
            content.categoryIdentifier = "THERMAL_WARNING"
        case .serious:
            content.title = "デバイス温度が高くなっています"
            content.body = "デバイスが熱くなっています。パフォーマンスが制限される可能性があります。"
            content.categoryIdentifier = "THERMAL_HIGH"
            content.interruptionLevel = .timeSensitive
        case .critical:
            content.title = "⚠️ デバイス温度が危険レベルです"
            content.body = "デバイスが非常に熱くなっています。すぐに冷却してください。"
            content.categoryIdentifier = "THERMAL_CRITICAL"
            content.interruptionLevel = .critical
        @unknown default:
            content.title = "温度状態が変化しました"
            content.body = "デバイスの熱状態が変化しました。"
            content.categoryIdentifier = "THERMAL_UNKNOWN"
        }
        
        // iOS 18の新機能：より詳細な通知情報
        content.targetContentIdentifier = "thermal-monitoring"
        content.relevanceScore = Double(newState.rawValue) / 3.0
        
        let request = UNNotificationRequest(
            identifier: "thermal-state-\(newState.rawValue)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            logger.info("Notification sent for thermal state: \(String(describing: newState))")
        } catch {
            logger.error("通知送信エラー: \(error.localizedDescription)")
        }
    }
    
    func thermalStateDescription() -> String {
        switch thermalState {
        case .nominal:
            return "正常"
        case .fair:
            return "良好"
        case .serious:
            return "注意"
        case .critical:
            return "危険"
        @unknown default:
            return "不明"
        }
    }
    
    func thermalStateColor() -> String {
        switch thermalState {
        case .nominal:
            return "green"
        case .fair:
            return "yellow"
        case .serious:
            return "orange"
        case .critical:
            return "red"
        @unknown default:
            return "gray"
        }
    }
    
    func recommendationText() -> String {
        switch thermalState {
        case .nominal:
            return "デバイスは正常に動作しています。"
        case .fair:
            return "軽微な発熱があります。重い処理は控えめに。"
        case .serious:
            return "デバイスが熱くなっています。処理を軽減することをお勧めします。"
        case .critical:
            return "デバイスが非常に熱くなっています。使用を控えて冷却してください。"
        @unknown default:
            return "熱状態を監視中です。"
        }
    }
}