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
        if let speedScale = audioQuery["speedScale"] as? Double {
            audioQuery["speedScale"] = speedScale * 0.95  // わずかに高速化
        }
        if let intonationScale = audioQuery["intonationScale"] as? Double {
            let adjustedScale = max(0.5, min(2.0, intonationScale * 1.1))  // イントネーション微調整
            audioQuery["intonationScale"] = adjustedScale
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
