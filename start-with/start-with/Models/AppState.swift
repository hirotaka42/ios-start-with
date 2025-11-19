import Foundation

class AppState: ObservableObject {
    @Published var currentScreen: Screen = .settings
    @Published var kuchisu: Int = 3
    @Published var minDigits: Int = 8
    @Published var maxDigits: Int = 16
    @Published var speechDuration: Double = 10.0 // 3-30秒
    @Published var currentCalculation: Calculation? = nil
    @Published var isAnswerRevealed: Bool = false
    @Published var showNumbersInQuestion: Bool = false

    let voiceReader = JapaneseVoiceReader()

    /// 問題を生成
    func generateQuestion() {
        currentCalculation = NumberGenerator.generateCalculation(
            kuchisu: kuchisu,
            minDigits: minDigits,
            maxDigits: maxDigits
        )
        isAnswerRevealed = false
        showNumbersInQuestion = false
        currentScreen = .question
    }

    /// 答えを表示
    func revealAnswer() {
        isAnswerRevealed = true
    }

    /// 次の問題へ
    func nextQuestion() {
        generateQuestion()
    }

    /// 設定画面に戻る
    func backToSettings() {
        currentScreen = .settings
    }
}

enum Screen {
    case settings
    case question
    case result
}
