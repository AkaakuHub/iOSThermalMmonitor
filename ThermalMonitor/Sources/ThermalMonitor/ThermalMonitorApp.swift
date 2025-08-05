import SwiftUI

#if os(iOS)
    @available(iOS 18.0, *)
    @main
    struct ThermalMonitorApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(ThermalManager.shared)
            }
        }
    }
#endif
