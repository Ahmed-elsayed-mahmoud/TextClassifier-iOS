//
//  Speaker.swift
//  Created by Ahmed El-Sayed on 06/01/2024.
//

import AVFoundation

protocol SpeakerProtocol {
    var isSpeaking: Bool { get }
    func speak(msg: String, completion: @escaping () -> Void)
    func stopSpeaking()
}

class Speaker: NSObject, SpeakerProtocol {
    static let shared: SpeakerProtocol = Speaker()
    private let synthesizer = AVSpeechSynthesizer()
    private var completion: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }

    func speak(msg: String, completion: @escaping () -> Void) {
        self.completion = completion

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setMode(.default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error.localizedDescription)
        }

        let speech = AVSpeechUtterance(string: msg)
        speech.rate = 0.5
        speech.volume = 1.0
        speech.voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "Martha" }) ?? AVSpeechSynthesisVoice()
        synthesizer.speak(speech)
    }

    func stopSpeaking() {
        completion = nil
        if synthesizer.isSpeaking {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completion?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    }
}
