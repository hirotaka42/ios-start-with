import AVFoundation

class JapaneseVoiceReader {
    private let voiceVOXClient = VoiceVOXClient()
    private let voiceVOXPlayer = VoiceVOXPlayer()
    @Published private(set) var isSpeakingValue = false

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

        // 最初の数値を読む
        let firstNumberText = convertNumberToJapanese(calculation.numbers[0])
        text += firstNumberText

        // 演算と被演算数を処理
        var previousOperator: Operator? = nil

        for i in 0..<calculation.operators.count {
            let currentOperator = calculation.operators[i]
            let operandText = convertNumberToJapanese(calculation.numbers[i + 1])

            // 数値とその後の演算記号の間に「えんなり」を挿入
            text += "えんなり"

            // 演算記号の決定
            if i == 0 {
                // 最初の演算
                if currentOperator == .subtract {
                    text += "ひいては"
                }
                // 最初が足し算の場合は何も追加しない
            } else {
                // 2番目以降の演算
                if previousOperator != currentOperator {
                    // 演算が変わった場合
                    if currentOperator == .subtract {
                        text += "ひいては"
                    } else if currentOperator == .add {
                        text += "くわえて"
                    }
                }
                // 同じ演算が続く場合は何も追加しない
            }

            text += operandText

            previousOperator = currentOperator
        }

        // 最後に「えんでは」を付加
        text += "えんでは"

        return text
    }

    /// 数字を日本語に変換（万、億、兆対応）
    /// 例：12345678 → じゅうにおくさんぜんよんひゃくごじゅうろくまんななせんはっぴゃくきゅうじゅうはち
    func convertNumberToJapanese(_ number: Int) -> String {
        if number == 0 {
            return "ぜろ"
        }

        let numberString = String(number)
        let digits = numberString.map { Int(String($0))! }
        let length = digits.count

        var result = ""
        var currentIndex = 0

        // 13桁以上：兆グループ処理
        if length >= 13 {
            let trillionLength = length - 12
            let trillionDigits = Array(digits[0..<trillionLength])
            // 兆が「1」だけの場合は「いっちょう」と促音を付ける
            if trillionDigits == [1] {
                result += "いっ" + "ちょう"
            } else if trillionDigits.count == 1 && trillionDigits[0] == 4 {
                // 4兆の場合は「よんちょう」
                result += "よん" + "ちょう"
            } else {
                result += readGroupDigits(trillionDigits, isLastGroup: false)
                result += "ちょう"
            }
            currentIndex = trillionLength
        }

        // 9～12桁：億グループ処理
        if length >= 9 {
            let occStartIndex = currentIndex
            let occEndIndex = length - 8
            let occEndIndexAdjusted = max(occStartIndex, occEndIndex)

            if occStartIndex < occEndIndexAdjusted {
                let occDigits = Array(digits[occStartIndex..<occEndIndexAdjusted])
                let occValue = occDigits.reduce(0) { $0 * 10 + $1 }
                if occValue > 0 {
                    // 8億の場合は「はっぴゃくおく」ではなく「はちおく」
                    if occDigits.count == 1 && occDigits[0] == 8 {
                        result += "はち" + "おく"
                    } else {
                        result += readGroupDigits(occDigits, isLastGroup: false)
                        result += "おく"
                    }
                }
            }
            currentIndex = occEndIndexAdjusted
        }

        // 5～8桁：万グループ処理
        if length >= 5 {
            let manStartIndex = currentIndex
            let manEndIndex = length - 4
            let manEndIndexAdjusted = max(manStartIndex, manEndIndex)

            if manStartIndex < manEndIndexAdjusted {
                let manDigits = Array(digits[manStartIndex..<manEndIndexAdjusted])
                let manValue = manDigits.reduce(0) { $0 * 10 + $1 }
                if manValue > 0 {
                    // 4万の場合は「よんまん」
                    if manDigits.count == 1 && manDigits[0] == 4 {
                        result += "よん" + "まん"
                    } else {
                        result += readGroupDigits(manDigits, isLastGroup: false)
                        result += "まん"
                    }
                }
            }
            currentIndex = manEndIndexAdjusted
        }

        // 1～4桁：最後のグループ処理
        let finalStartIndex = currentIndex
        let finalDigits = Array(digits[finalStartIndex..<length])
        result += readGroupDigits(finalDigits, isLastGroup: true)

        return result
    }

    /// グループ内のデジットを読む（万、億、兆用）
    private func readGroupDigits(_ digits: [Int], isLastGroup: Bool) -> String {
        var result = ""
        let length = digits.count

        for (index, digit) in digits.enumerated() {
            let position = length - index - 1

            if digit == 0 {
                continue
            }

            if position == 3 {
                // 千の位
                if digit == 1 && !isLastGroup {
                    result += "せん"
                } else if digit == 1 && isLastGroup {
                    // 1千の場合は「いっせん」と促音を付ける
                    result += "いっ" + "せん"
                } else if digit == 3 && isLastGroup {
                    // 3千の場合は「さんぜん」
                    result += "さんぜん"
                } else if digit == 8 && isLastGroup {
                    // 8千の場合は「はっせん」と促音を付ける
                    result += "はっ" + "せん"
                } else {
                    result += readDigitForPosition(digit, position: position)
                }
            } else if position == 2 {
                // 百の位
                if digit == 1 && !isLastGroup {
                    result += "ひゃく"
                } else {
                    result += readHyakuDigit(digit)
                }
            } else if position == 1 {
                // 十の位
                if digit == 1 && !isLastGroup {
                    result += "じゅう"
                } else if digit == 1 && isLastGroup {
                    result += "いち" + "じゅう"
                } else {
                    result += readDigitForTensPlace(digit) + "じゅう"
                }
            } else if position == 0 {
                // 一の位
                result += readDigitForOnesPlace(digit)
            }
        }

        return result
    }

    /// 数字を読む（一の位用）- 4は「よ」
    private func readDigitForOnesPlace(_ digit: Int) -> String {
        switch digit {
        case 0: return ""
        case 1: return "いち"
        case 2: return "に"
        case 3: return "さん"
        case 4: return "よ"
        case 5: return "ご"
        case 6: return "ろく"
        case 7: return "なな"
        case 8: return "はち"
        case 9: return "きゅう"
        default: return ""
        }
    }

    /// 数字を読む（十の位用）- 4は「よん」
    private func readDigitForTensPlace(_ digit: Int) -> String {
        switch digit {
        case 0: return ""
        case 1: return "いち"
        case 2: return "に"
        case 3: return "さん"
        case 4: return "よん"
        case 5: return "ご"
        case 6: return "ろく"
        case 7: return "なな"
        case 8: return "はち"
        case 9: return "きゅう"
        default: return ""
        }
    }

    /// 百の位を読む
    private func readHyakuDigit(_ digit: Int) -> String {
        switch digit {
        case 1: return "ひゃく"
        case 2: return "にひゃく"
        case 3: return "さんびゃく"
        case 4: return "よんひゃく"
        case 5: return "ごひゃく"
        case 6: return "ろっぴゃく"
        case 7: return "ななひゃく"
        case 8: return "はっぴゃく"
        case 9: return "きゅうひゃく"
        default: return ""
        }
    }

    /// 数字を位置に応じて読む
    private func readDigitForPosition(_ digit: Int, position: Int) -> String {
        let digitName = readDigitForHigherPositions(digit)
        let positionName = getPositionName(position)
        return digitName + positionName
    }

    /// 数字を読む（千の位以上用）
    private func readDigitForHigherPositions(_ digit: Int) -> String {
        switch digit {
        case 0: return ""
        case 1: return "いち"
        case 2: return "に"
        case 3: return "さん"
        case 4: return "よん"
        case 5: return "ご"
        case 6: return "ろく"
        case 7: return "なな"
        case 8: return "はち"
        case 9: return "きゅう"
        default: return ""
        }
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

    /// テキストを音声で再生（VoiceVOX）
    func speakWithDuration(_ text: String, duration: Double) {
        // 空のテキストをチェック
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        isSpeakingValue = true

        Task {
            do {
                // VoiceVOXで音声を合成
                let audioData = try await voiceVOXClient.synthesize(text: text)

                // 音声を再生
                try voiceVOXPlayer.play(audioData: audioData) {
                    self.isSpeakingValue = false
                }
            } catch {
                print("VoiceVOX error: \(error)")
                isSpeakingValue = false
            }
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
        voiceVOXPlayer.stop()
        isSpeakingValue = false
    }

    /// 再生中かどうか
    func isSpeaking() -> Bool {
        return voiceVOXPlayer.isPlaying()
    }
}
