
import SwiftUI

@main
struct ROBOShopApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(RoboTheme.background.ignoresSafeArea())
                .preferredColorScheme(.light)
        }
    }
}
