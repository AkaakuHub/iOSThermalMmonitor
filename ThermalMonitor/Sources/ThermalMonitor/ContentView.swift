import SwiftUI

struct ContentView: View {
    @EnvironmentObject var thermalManager: ThermalManager
    @State private var showDetails = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
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
        }
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("通知設定") {
                    Text("通知は温度状態が変化した際に自動で送信されます")
                        .foregroundStyle(.secondary)
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
}

#Preview {
    ContentView()
        .environmentObject(ThermalManager.shared)
}

#Preview("Settings") {
    SettingsView()
}