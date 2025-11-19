import SwiftUI

struct ResultView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("完了")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding()

            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)

                Text("問題が完了しました")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(30)
            .backdrop()

            Spacer()

            // ボタン
            HStack(spacing: 15) {
                Button(action: { appState.backToSettings() }) {
                    Text("設定に戻る")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: { appState.nextQuestion() }) {
                    Text("次の問題")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.2, green: 0.9, blue: 1.0), Color(red: 0.0, green: 0.5, blue: 1.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        ResultView(appState: AppState())
    }
}
