import SwiftUI

struct QuestionView: View {
    @ObservedObject var appState: AppState
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 20) {
            // タイトル
            Text("問題")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding()

            Spacer()

            // 問題表示
            if let calculation = appState.currentCalculation {
                VStack(spacing: 20) {
                    // 問題の数字と演算子をレイアウト表示
                    QuestionDisplayLayout(calculation: calculation, showNumbers: appState.showNumbersInQuestion)
                        .padding()
                        .backdrop()

                    // 読み上げボタン
                    Button(action: {
                        isPlaying = true
                        // 読み上げ用の日本語テキスト（コンマなし）を生成
                        let speechText = convertCalculationToJapaneseForSpeech(calculation)
                        appState.voiceReader.speakWithDuration(
                            speechText,
                            duration: appState.speechDuration
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + appState.speechDuration + 0.5) {
                            isPlaying = false
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text(isPlaying ? "読み上げ中..." : "読み上げる")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isPlaying ? Color.green : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(isPlaying)

                    // 数字表示/非表示トグル
                    Button(action: { appState.showNumbersInQuestion.toggle() }) {
                        HStack(spacing: 10) {
                            Image(systemName: appState.showNumbersInQuestion ? "eye.fill" : "eye.slash.fill")
                            Text(appState.showNumbersInQuestion ? "数字を非表示" : "数字を表示")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .backdrop()

                Spacer()

                // 答え表示エリア（タップで表示）
                AnswerTapView(calculation: calculation, isRevealed: appState.isAnswerRevealed) {
                    appState.revealAnswer()
                }
                .padding()

                Spacer()

                // ボタン
                HStack(spacing: 15) {
                    Button(action: { appState.backToSettings() }) {
                        Text("戻る")
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
        }
        .padding()
    }

    /// 計算式を日本語に変換（読み上げ用：コンマなし）
    private func convertCalculationToJapaneseForSpeech(_ calculation: Calculation) -> String {
        var text = "ねがいましては、"

        for i in 0..<calculation.numbers.count {
            // 数字をそのまま読み上げ用日本語に変換
            let numberText = JapaneseVoiceReader().convertNumberToJapanese(calculation.numbers[i])
            text += numberText + "、えんなり、"

            if i < calculation.operators.count {
                let operatorText = calculation.operators[i] == .add ? "くわえて、" : "ひいては、"
                text += operatorText
            }
        }

        text = text.trimmingCharacters(in: CharacterSet(charactersIn: "、"))
        text += "、えんでは"

        return text
    }

    /// 計算式を日本語に変換（表示用）
    private func convertCalculationToJapanese(_ calculation: Calculation) -> String {
        return convertCalculationToJapaneseForSpeech(calculation)
    }
}

// 問題表示レイアウト（数字を左に列挙、演算子を右に固定）
struct QuestionDisplayLayout: View {
    let calculation: Calculation
    let showNumbers: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showNumbers {
                // 数字を上から縦に列挙
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<calculation.numbers.count, id: \.self) { i in
                        HStack(spacing: 12) {
                            // 数字（左寄せ）
                            Text(CurrencyFormatter.formatWithComma(calculation.numbers[i]))
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.2, green: 0.9, blue: 1.0))

                            Spacer()

                            // 演算子（右寄せ、最後の数字には演算子なし）
                            if i < calculation.operators.count {
                                Text(calculation.operators[i] == .add ? "+" : "−")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                }
            } else {
                Text("(読み上げ後に「数字を表示」で表示)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(height: 100)
            }
        }
    }
}

// 答え表示エリア（タップで表示）
struct AnswerTapView: View {
    let calculation: Calculation
    let isRevealed: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(isRevealed ? "答え:" : "答えを表示するにはタップ")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            if isRevealed {
                Text(CurrencyFormatter.formatWithComma(calculation.result))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(calculation.result >= 0 ? Color(red: 0.2, green: 1.0, blue: 0.4) : Color(red: 1.0, green: 0.3, blue: 0.3))
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding()
        .backdrop()
        .onTapGesture {
            if !isRevealed {
                onTap()
            }
        }
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        QuestionView(appState: AppState())
    }
}
