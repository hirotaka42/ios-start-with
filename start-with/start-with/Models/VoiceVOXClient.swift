import Foundation

class VoiceVOXClient {
    // VoiceVOX Engine のベースURL
    private let baseURL: String

    // 話者ID（四国めたん ノーマル）
    private let defaultSpeakerId = 2

    init(baseURL: String = "http://127.0.0.1:50021") {
        self.baseURL = baseURL
    }

    /// テキストを音声に変換してWAVデータを取得
    func synthesize(text: String, speakerId: Int? = nil) async throws -> Data {
        let speaker = speakerId ?? defaultSpeakerId

        // ステップ1: audio_query を取得
        var audioQuery = try await createAudioQuery(text: text, speaker: speaker)

        // ステップ2: 音声パラメータを調整
        // speedScale: わずかに速度を上げて、音声の鮮明性を向上させ誤認識を防止
        // intonationScale: 若干イントネーションを上げて、明確性を向上

        // 「はっちょう」「はっせん」「はち」「よんまん」を含む場合は強調
        let containsHachi = text.contains("はっ") || text.contains("はち")
        let containsYonman = text.contains("よんまん")
        let requiresEnhancement = containsHachi || containsYonman

        if let speedScale = audioQuery["speedScale"] as? Double {
            if requiresEnhancement {
                audioQuery["speedScale"] = speedScale * 0.85  // より高速化して鮮明性を大幅向上
            } else {
                audioQuery["speedScale"] = speedScale * 0.95
            }
        }
        if let intonationScale = audioQuery["intonationScale"] as? Double {
            let baseScale = requiresEnhancement ? 1.4 : 1.1  // はち系・よんまんはイントネーションを大幅に上げる
            let adjustedScale = max(0.5, min(2.0, intonationScale * baseScale))
            audioQuery["intonationScale"] = adjustedScale
        }

        // 「はち」「よんまん」が含まれる場合、pauseLength（ポーズ）を調整して明確性を向上
        if let acc = audioQuery["accent_phrases"] as? [[String: Any]] {
            var modifiedAcc = acc
            for i in 0..<modifiedAcc.count {
                if var phrase = modifiedAcc[i] as? [String: Any] {
                    // ポーズ時間を調整（はち系・よんまんの単語は区切りを明確に）
                    if text.contains("はち") || text.contains("はっ") || text.contains("よんまん") {
                        if let pauseLength = phrase["pause_length"] as? Double {
                            phrase["pause_length"] = max(pauseLength, 0.15)
                            modifiedAcc[i] = phrase
                        }
                        // 「は」と「ち」の境界を明確にするため、vowel lengthを調整
                        if let morph = phrase["moras"] as? [[String: Any]] {
                            var modifiedMorph = morph
                            for j in 0..<modifiedMorph.count {
                                if var mora = modifiedMorph[j] as? [String: Any] {
                                    if let moraText = mora["text"] as? String {
                                        if moraText == "ち" || moraText == "チ" {
                                            if let vowelLength = mora["vowel_length"] as? Double {
                                                mora["vowel_length"] = vowelLength * 1.2
                                                modifiedMorph[j] = mora
                                            }
                                        }
                                    }
                                }
                            }
                            phrase["moras"] = modifiedMorph
                        }
                    }
                }
            }
            audioQuery["accent_phrases"] = modifiedAcc
        }

        // ステップ3: 音声を合成
        let audioData = try await synthesizeVoice(audioQuery: audioQuery, speaker: speaker)

        return audioData
    }

    /// AudioQueryを生成
    private func createAudioQuery(text: String, speaker: Int) async throws -> [String: Any] {
        guard var urlComponents = URLComponents(string: "\(baseURL)/audio_query") else {
            throw VoiceVOXError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "speaker", value: String(speaker))
        ]

        guard let url = urlComponents.url else {
            throw VoiceVOXError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw VoiceVOXError.requestFailed
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw VoiceVOXError.invalidResponse
        }

        return json
    }

    /// 音声を合成
    private func synthesizeVoice(audioQuery: [String: Any], speaker: Int) async throws -> Data {
        guard var urlComponents = URLComponents(string: "\(baseURL)/synthesis") else {
            throw VoiceVOXError.invalidURL
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "speaker", value: String(speaker))
        ]

        guard let url = urlComponents.url else {
            throw VoiceVOXError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: audioQuery)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw VoiceVOXError.requestFailed
        }

        return data
    }

    /// 利用可能な話者一覧を取得
    func getSpeakers() async throws -> [[String: Any]] {
        guard let url = URL(string: "\(baseURL)/speakers") else {
            throw VoiceVOXError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw VoiceVOXError.requestFailed
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw VoiceVOXError.invalidResponse
        }

        return json
    }
}

enum VoiceVOXError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case engineNotRunning
}
