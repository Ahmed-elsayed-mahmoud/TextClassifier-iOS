//
//  SpeechRecognizer.swift
//  Created by Ahmed El-Sayed on 06/01/2024.
//

import UIKit
import Speech
import AVFoundation

typealias SpeechTextHandler = (String?) -> Void

protocol Recordable {
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus { get }
    func requestAuthorization(_ statusHandler: @escaping (Bool) -> Void)
    func startRecording(textHandler: @escaping SpeechTextHandler)
    func stopRecording()
    func isRecording() -> Bool
}

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate, Recordable {
    static let shared: Recordable = SpeechRecognizer()
    private static let AUDIO_BUFFER_SIZE: UInt32 = 1024
    private let speechRecognizer: SFSpeechRecognizer
    private var speechRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var textHandler: SpeechTextHandler?
    private var timer: Timer?

    override public convenience init() {
        if SFSpeechRecognizer()?.isAvailable ?? false {
            self.init(speechRecognizer: SFSpeechRecognizer())
        } else {
            self.init(locale: Locale(identifier: "en"))
        }
    }

    public convenience init(locale: Locale) {
        self.init(speechRecognizer: SFSpeechRecognizer(locale: locale))
    }

    private init(speechRecognizer: SFSpeechRecognizer?) {
        guard let speechRecognizer = speechRecognizer else {
            fatalError("SFSpeechRecognizer is nil. Locale not supported.")
        }
        self.speechRecognizer = speechRecognizer
        self.speechRecognizer.defaultTaskHint = .confirmation
        super.init()
    }

    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
    }

    class func supportedLocales() -> Set<Locale> {
        return SFSpeechRecognizer.supportedLocales()
    }

    class func localeSupported(_ locale: Locale) -> Bool {
        return SFSpeechRecognizer.supportedLocales().contains(locale)
    }

    func requestAuthorization(_ statusHandler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                DispatchQueue.main.async {
                    statusHandler(true)
                }
            default:
                DispatchQueue.main.async {
                    statusHandler(false)
                }
            }
        }
    }

    func isRecording() -> Bool {
        return audioEngine.isRunning
    }

    func startRecording(textHandler: @escaping SpeechTextHandler) {
        requestAuthorization { [weak self] (authStatus) in
            guard let `self` = self else { return }
            self.textHandler = textHandler
            if authStatus {
                if !self.audioEngine.isRunning {
                    self.record()
                }
            } else {
                textHandler(nil)
            }
        }
    }

    private func record() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error.localizedDescription)
        }

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)

        let speechRequest = SFSpeechAudioBufferRecognitionRequest()
        speechRequest.shouldReportPartialResults = true
//        speechRequest.customizedLanguageModel
        self.speechRequest = speechRequest

        node.installTap(onBus: 0,
                        bufferSize: SpeechRecognizer.AUDIO_BUFFER_SIZE,
                        format: recordingFormat) { [weak self] (buffer, _) in
            self?.speechRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            textHandler?(nil)
            return
        }

        createNewTimer()

        speechTask = speechRecognizer.recognitionTask(with: speechRequest) { [self] (result, _) in
            guard self.isRecording() else { return }
            self.createNewTimer()
            if let result {
                let transcription = result.bestTranscription
                self.textHandler?(transcription.formattedString)
            }
        }
    }

    private func createNewTimer() {
        guard isRecording() else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(didFinishTalking), userInfo: nil, repeats: false)
    }

    @objc private func didFinishTalking() {
        textHandler?(nil)
        stopRecording()
    }

    func stopRecording() {
        if audioEngine.isRunning {
            speechRequest?.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            speechTask?.cancel()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }

        speechTask = nil
        speechRequest = nil
        timer?.invalidate()
        textHandler = nil
    }

    deinit {
        stopRecording()
    }
}
