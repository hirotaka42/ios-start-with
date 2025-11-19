import SwiftUI

struct QuestionView: View {
    @ObservedObject var appState: AppState
    @State private var speechTimer: Timer?

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

                    // 読み上げ/ストップボタン
                    Button(action: {
                        if appState.isSpeaking {
                            appState.stopSpeech()
                            speechTimer?.invalidate()
                            speechTimer = nil
                        } else {
                            appState.isSpeaking = true
                            // 読み上げ用の日本語テキスト（コンマなし）を生成
                            let speechText = convertCalculationToJapaneseForSpeech(calculation)
                            appState.voiceReader.speakWithDuration(
                                speechText,
                                duration: appState.speechDuration
                            )
                            // タイマーで再生終了を正確に追跡
                            speechTimer?.invalidate()
                            speechTimer = Timer.scheduledTimer(withTimeInterval: appState.speechDuration + 0.5, repeats: false) { _ in
                                appState.isSpeaking = false
                                speechTimer = nil
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: appState.isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                            Text(appState.isSpeaking ? "停止" : "読み上げる")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(appState.isSpeaking ? Color.red : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }

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
                                appState.isAnswerRevealed
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 0.2, green: 0.9, blue: 1.0), Color(red: 0.0, green: 0.5, blue: 1.0)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
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
                    .disabled(!appState.isAnswerRevealed)
                }
                .padding()
            }
        }
        .padding()
        .onDisappear {
            speechTimer?.invalidate()
            speechTimer = nil
            appState.stopSpeech()
        }
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

// 問題表示レイアウト（演算子を左先頭、数字を右寄せで揃える）
struct QuestionDisplayLayout: View {
    let calculation: Calculation
    let showNumbers: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showNumbers {
                // 数字を上から縦に列挙
                ForEach(0..<calculation.numbers.count, id: \.self) { i in
                    HStack(spacing: 16) {
                        // 演算子（左先頭、最初の数字には演算子なし）
                        if i > 0 {
                            Text(calculation.operators[i - 1] == .add ? "+" : "−")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                                .frame(width: 24, alignment: .leading)
                        } else {
                            // 最初の数字は演算子の代わりにスペースを確保
                            Text("")
                                .frame(width: 24, alignment: .leading)
                        }

                        // 数字（右寄せで桁数を揃える）
                        Text(CurrencyFormatter.formatWithComma(calculation.numbers[i]))
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(red: 0.2, green: 0.9, blue: 1.0))
                            .frame(maxWidth: .infinity, alignment: .trailing)
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
                let answerText = CurrencyFormatter.formatWithComma(calculation.result)
                let fontSize = calculateFontSize(for: answerText)

                Text(answerText)
                    .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                    .foregroundColor(calculation.result >= 0 ? Color(red: 0.2, green: 1.0, blue: 0.4) : Color(red: 1.0, green: 0.3, blue: 0.3))
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                    .lineLimit(1)
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

    /// テキストの長さに応じてフォントサイズを計算
    private func calculateFontSize(for text: String) -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 60 // パディングとマージンを考慮
        let characterCount = text.count

        // 1文字あたりの幅を計算（monospaced fontで約8ptあたり6px）
        let baseSize: CGFloat = 32
        let minSize: CGFloat = 16
        let maxSize: CGFloat = 32

        // 文字数が多いほどフォントサイズを小さくする
        let calculatedSize = baseSize - CGFloat(max(0, characterCount - 10)) * 1.5

        return min(maxSize, max(minSize, calculatedSize))
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        QuestionView(appState: AppState())
    }
}
