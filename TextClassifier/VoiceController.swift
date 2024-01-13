//
//  VoiceController.swift
//  Created by Ahmed El-Sayed on 06/01/2024.
//

import Foundation
import UIKit

protocol VoiceControllerProtocol {
    func enablePermissions(callback: @escaping () -> Void)
    func confirmResult(message: String, viewController: UIViewController, completion: @escaping (String?) -> Void)
    func speakFewWords(message: String, viewController: UIViewController, completion: (() -> Void)?)
    func stopVoice()
}

extension VoiceControllerProtocol {
    func speakFewWords(message: String, viewController: UIViewController) {
        speakFewWords(message: message, viewController: viewController, completion: nil)
    }
}

class VoiceController: VoiceControllerProtocol {
    static let shared: VoiceControllerProtocol = VoiceController()
    private let speaker: SpeakerProtocol
    private let speechRecognizer: Recordable
    private let voiceOverlayController: VoiceStateOverlayViewController
    private var lastSpokenWords: String?

    init(speaker: SpeakerProtocol = Speaker.shared,
         speechRecognizer: Recordable = SpeechRecognizer.shared) {
        self.speaker = speaker
        self.speechRecognizer = speechRecognizer
        self.voiceOverlayController = VoiceStateOverlayViewController()
    }

    private var isSpeechRecongitionEnabled: Bool {
        return speechRecognizer.authorizationStatus == .authorized
    }

    func enablePermissions(callback: @escaping () -> Void) {
        requestSpeechRecognizer(callback: callback)
    }

    func requestSpeechRecognizer(callback: @escaping () -> Void) {
        speechRecognizer.requestAuthorization { _ in
            callback()
        }
    }

    private func presentVoiceOverlay(viewController: UIViewController, completion: @escaping (String?) -> Void) {
        reset {
            viewController.present(self.voiceOverlayController, animated: true)
            self.voiceOverlayController.dismissCallback = {
                self.reset {
                    completion(nil)
                }
            }
        }
    }

    func confirmResult(message: String, viewController: UIViewController, completion: @escaping (String?) -> Void) {
        presentVoiceOverlay(viewController: viewController, completion: completion)
        voiceOverlayController.changeState(to: .speaking(phrase: message))
        speaker.speak(msg: message) {
            self.voiceOverlayController.changeState(to: .listening(suggestion: ""))
            self.speechRecognizer.startRecording { text in
                guard let text else {
                    return self.reset {
                        completion(nil)
                    }
                }
                completion(text)
            }
        }
    }

    private func reset(completion: @escaping () -> Void) {
        self.lastSpokenWords = nil
        self.stopVoice()
        self.voiceOverlayController.dismiss(animated: true) {
            completion()
        }
    }

    func speakFewWords(message: String, viewController: UIViewController, completion: (() -> Void)? = nil) {
        presentVoiceOverlay(viewController: viewController) { _ in }
        voiceOverlayController.changeState(to: .speaking(phrase: message))
        speaker.speak(msg: message) {
            self.reset {
                completion?()
            }
        }
    }

    func stopVoice() {
        speechRecognizer.stopRecording()
        speaker.stopSpeaking()
    }
}
