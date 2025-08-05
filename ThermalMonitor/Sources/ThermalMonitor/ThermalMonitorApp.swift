import SwiftUI

@main
struct ThermalMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ThermalManager.shared)
        }
    }
}