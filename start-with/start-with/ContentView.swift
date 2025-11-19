import SwiftUI

struct ContentView: View {
    @StateObject var appState = AppState()

    var body: some View {
        ZStack {
            // Liquid Glass Background
            LiquidGlassBackground()

            VStack {
                switch appState.currentScreen {
                case .settings:
                    SettingsView(appState: appState)
                case .question:
                    QuestionView(appState: appState)
                case .result:
                    ResultView(appState: appState)
                }
            }
        }
        .preferredColorScheme(nil)
    }
}

#Preview {
    ContentView()
}
