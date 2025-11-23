import AVFoundation

class VoiceVOXPlayer: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var onPlaybackFinished: (() -> Void)?

    /// WAVデータを再生
    func play(audioData: Data, onFinished: @escaping () -> Void = {}) throws {
        // 既存の再生を停止
        audioPlayer?.stop()

        // オーディオセッションの設定
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

        // AVAudioPlayerでWAVデータを再生
        audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()

        onPlaybackFinished = onFinished
        audioPlayer?.play()
    }

    /// 再生を停止
    func stop() {
        audioPlayer?.stop()
    }

    /// 再生中かどうか
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackFinished?()
    }
}
