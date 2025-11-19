import AVFoundation

class JapaneseVoiceReader {
    private let synthesizer = AVSpeechSynthesizer()

    /// 計算式を日本語で読み上げ
    func readCalculation(_ calculation: Calculation) {
        let japaneseText = convertCalculationToJapanese(calculation)
        speak(japaneseText)
    }

    /// 数字を日本語で読み上げ
    func readNumber(_ number: Int) {
        let japaneseText = convertNumberToJapanese(number)
        speak(japaneseText)
    }

    /// 計算式を日本語テキストに変換
    private func convertCalculationToJapanese(_ calculation: Calculation) -> String {
        var text = "ねがいましては、"

        for i in 0..<calculation.numbers.count {
            let numberText = convertNumberToJapanese(calculation.numbers[i])
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

    /// 数字を日本語に変換
    /// 例：12345678 → せんにひゃくさんじゅうよんまんごせんろっぴゃくななじゅうはち
    func convertNumberToJapanese(_ number: Int) -> String {
        if number == 0 {
            return "ゼロ"
        }

        let numberString = String(number)
        let digits = numberString.map { Int(String($0))! }
        let length = digits.count

        var result = ""

        // 各桁を処理（万位から始まる）
        for (index, digit) in digits.enumerated() {
            let position = length - index - 1 // 位を計算

            if digit == 0 {
                continue
            }

            // 数字の読み
            let digitText = getDigitName(digit)

            // 位の読み
            let positionText = getPositionName(position)

            result += digitText + positionText
        }

        return result
    }

    /// 数字の読みを返す（0-9）
    private func getDigitName(_ digit: Int) -> String {
        let names = ["", "いち", "に", "さん", "し", "ご", "ろく", "しち", "はち", "きゅう"]
        return names[digit]
    }

    /// 位の読みを返す
    private func getPositionName(_ position: Int) -> String {
        switch position {
        case 0:
            return ""
        case 1:
            return "じゅう"
        case 2:
            return "ひゃく"
        case 3:
            return "せん"
        case 4:
            return "まん"
        case 5:
            return "じゅうまん"
        case 6:
            return "ひゃくまん"
        case 7:
            return "せんまん"
        case 8:
            return "おく"
        case 9:
            return "じゅうおく"
        case 10:
            return "ひゃくおく"
        case 11:
            return "せんおく"
        default:
            return ""
        }
    }

    /// テキストを音声で再生（指定秒数で完了）
    func speakWithDuration(_ text: String, duration: Double) {
        // 既存の再生を停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // 空のテキストをチェック
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            // 読み上げ速度の計算：duration秒で読み上げ完了するように調整
            utterance.rate = calculateRate(text, duration: duration)
            utterance.pitchMultiplier = 1.0
            utterance.preUtteranceDelay = 0.0
            utterance.postUtteranceDelay = 0.0

            synthesizer.speak(utterance)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    /// テキストを音声で再生
    private func speak(_ text: String) {
        speakWithDuration(text, duration: 10.0) // デフォルト10秒
    }

    /// 指定秒数で読み上げ完了するレートを計算
    private func calculateRate(_ text: String, duration: Double) -> Float {
        // 最小値0.1、最大値2.0
        // 3秒は速く、30秒はゆっくり
        let baseRate = Float(10.0 / max(3.0, min(30.0, duration)))
        return min(max(0.1, baseRate * 0.5), 2.0)
    }

    /// 再生を停止
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
