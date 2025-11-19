import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 30) {
            // タイトル
            VStack(spacing: 10) {
                Text("そろばん")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("読み上げ算練習")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .backdrop()

            // 口数の選択
            VStack(alignment: .leading, spacing: 15) {
                Text("口数を選択してください")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 10) {
                    ForEach(2...10, id: \.self) { num in
                        Button(action: { appState.kuchisu = num }) {
                            Text("\(num)")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(appState.kuchisu == num ? Color(red: 0.2, green: 0.9, blue: 1.0) : Color.white.opacity(0.1))
                                .foregroundColor(appState.kuchisu == num ? .black : .white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding()
            .backdrop()

            // 読み上げ速度の選択
            VStack(alignment: .leading, spacing: 15) {
                Text("読み上げ速度を設定してください")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    HStack {
                        Text("読み上げ時間:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(appState.speechDuration))秒")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                    }
                    Slider(value: $appState.speechDuration, in: 3...30, step: 1)
                        .accentColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                }
            }
            .padding()
            .backdrop()

            // 桁数範囲の選択
            VStack(alignment: .leading, spacing: 15) {
                Text("桁数範囲を選択してください")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    HStack {
                        Text("最小桁数:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(appState.minDigits)桁")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                    }
                    Slider(value: Binding(
                        get: { Double(appState.minDigits) },
                        set: {
                            let newValue = Int($0)
                            if newValue <= appState.maxDigits {
                                appState.minDigits = newValue
                            }
                        }
                    ), in: 8...15)
                        .accentColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("最大桁数:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(appState.maxDigits)桁")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                    }
                    Slider(value: Binding(
                        get: { Double(appState.maxDigits) },
                        set: { appState.maxDigits = Int($0) }
                    ), in: Double(appState.minDigits)...16)
                        .accentColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                }
            }
            .padding()
            .backdrop()

            Spacer()

            // スタートボタン
            Button(action: { appState.generateQuestion() }) {
                Text("問題を生成")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.2, green: 0.9, blue: 1.0), Color(red: 0.0, green: 0.5, blue: 1.0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        SettingsView(appState: AppState())
    }
}
