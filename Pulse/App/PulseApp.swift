import SwiftUI

@main
struct PulseApp: App {
  
  @State private var coordinator = AppCoordinator()
  
  var body: some Scene {
    WindowGroup {
      coordinator.build()
    }
  }
}
