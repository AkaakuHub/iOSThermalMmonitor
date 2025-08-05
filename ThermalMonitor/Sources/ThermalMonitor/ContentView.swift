import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var thermalManager: ThermalManager
    @State private var showDetails = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 通知権限警告バナー
                if thermalManager.notificationPermissionStatus != .authorized {
                    notificationPermissionBanner
                }
                
                headerView
                thermalStatusCard
                recommendationView
                timestampView

                Button("詳細設定") {
                    showDetails = true
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("サーマルモニター")
            .sheet(isPresented: $showDetails) {
                SettingsView()
            }
            .onAppear {
                // アプリ表示時に通知権限状態を再チェック
                thermalManager.checkNotificationPermissionStatus()
            }
            .onChange(of: scenePhase) { _, newPhase in
                // アプリがアクティブになった時に通知権限を再チェック
                if newPhase == .active {
                    thermalManager.checkNotificationPermissionStatus()
                }
            }
        }
    }
    
    // 通知権限警告バナー
    private var notificationPermissionBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("通知が無効です")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("温度変化の通知を受け取るには通知を許可してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                if thermalManager.notificationPermissionStatus == .notDetermined {
                    Button("通知を許可") {
                        thermalManager.requestNotificationPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    Button("設定を開く") {
                        if let settingsURL = URL(string: "app-settings:") {
                            openURL(settingsURL)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.yellow.opacity(0.1))
                .stroke(.yellow.opacity(0.3), lineWidth: 1)
        )
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "thermometer")
                .font(.system(size: 50))
                .foregroundStyle(thermalStateColor)
                .symbolEffect(.pulse, isActive: thermalManager.thermalState != .nominal)
            
            Text("デバイスサーマルモニター")
                .font(.title2)
                .fontWeight(.medium)
        }
    }
    
    private var thermalStatusCard: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(thermalStateColor)
                    .frame(width: 15, height: 15)
                    .scaleEffect(thermalManager.thermalState == .critical ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), 
                              value: thermalManager.thermalState == .critical)
                
                Text("現在の状態")
                    .font(.headline)
                
                Spacer()
            }
            
            Text(thermalManager.thermalStateDescription())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(thermalStateColor)
                .contentTransition(.numericText())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
    }
    
    private var recommendationView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("推奨事項")
                    .font(.headline)
                Spacer()
            }
            
            Text(thermalManager.recommendationText())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.thickMaterial)
                .shadow(color: .primary.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var timestampView: some View {
        VStack(spacing: 5) {
            Text("最終更新")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(DateFormatter.displayFormatter.string(from: thermalManager.lastStateChange))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    // SwiftUI 6のColor API
    private var thermalStateColor: Color {
        switch thermalManager.thermalState {
        case .nominal:
            return .green
        case .fair:
            return .yellow
        case .serious:
            return .orange
        case .critical:
            return .red
        @unknown default:
            return .gray
        }
    }
}

extension DateFormatter {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var thermalManager: ThermalManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("通知設定")) {
                    HStack {
                        Image(systemName: notificationStatusIcon)
                            .foregroundColor(notificationStatusColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("通知の状態")
                                .font(.headline)
                            Text(notificationStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if thermalManager.notificationPermissionStatus != .authorized {
                            Button(thermalManager.notificationPermissionStatus == .notDetermined ? "許可" : "設定") {
                                if thermalManager.notificationPermissionStatus == .notDetermined {
                                    thermalManager.requestNotificationPermission()
                                } else {
                                    if let settingsURL = URL(string: "app-settings:") {
                                        openURL(settingsURL)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    
                    Text("通知は温度状態が変化した際に自動で送信されます")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
                
                Section("アプリについて") {
                    LabeledContent("バージョン", value: "1.0")
                    LabeledContent("ビルド", value: "1")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 通知状態のアイコン
    private var notificationStatusIcon: String {
        switch thermalManager.notificationPermissionStatus {
        case .authorized:
            return "bell.fill"
        case .denied, .ephemeral, .provisional:
            return "bell.slash.fill"
        case .notDetermined:
            return "bell"
        @unknown default:
            return "bell.badge.questionmark"
        }
    }
    
    // 通知状態の色
    private var notificationStatusColor: Color {
        switch thermalManager.notificationPermissionStatus {
        case .authorized:
            return .green
        case .denied, .ephemeral:
            return .red
        case .provisional:
            return .orange
        case .notDetermined:
            return .blue
        @unknown default:
            return .gray
        }
    }
    
    // 通知状態のテキスト
    private var notificationStatusText: String {
        switch thermalManager.notificationPermissionStatus {
        case .authorized:
            return "通知が有効です"
        case .denied:
            return "通知が拒否されています"
        case .ephemeral:
            return "一時的に無効です"
        case .provisional:
            return "仮許可状態です"
        case .notDetermined:
            return "許可されていません"
        @unknown default:
            return "状態不明"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThermalManager.shared)
}

#Preview("Settings") {
    SettingsView()
}