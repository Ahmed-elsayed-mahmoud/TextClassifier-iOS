//
//  VoiceStateOverlayViewController.swift
//  Created by Ahmed El-Sayed on 06/01/2024.
//

import UIKit
import SnapKit

enum VoiceState {
    case listening(suggestion: String)
    case speaking(phrase: String)
}

class VoiceStateOverlayViewController: UIViewController {
    var dismissCallback: (() -> Void)?

    private lazy var dimcontainerView: UIView = {
        let dimcontainerView = UIView()
        dimcontainerView.backgroundColor = UIColor(red: 33.0 / 255.0, green: 48.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
        dimcontainerView.alpha = 0.38
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        dimcontainerView.addGestureRecognizer(tapGesture)
        dimcontainerView.isUserInteractionEnabled = true
        return dimcontainerView
    }()

    private lazy var shadowView: UIView = {
        let shadowView = UIView()
        return shadowView
    }()

    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.masksToBounds = true
        backgroundView.addSubview(shadowView)
        backgroundView.addSubview(headerView)
        backgroundView.addSubview(voiceView)
        backgroundView.addSubview(cancelButton)
        return backgroundView
    }()

    private lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.addSubview(listeningLabel)
        headerView.addSubview(speakingLabel)
        return headerView
    }()

    private lazy var listeningLabel: UILabel = {
        let listeningLabel = UILabel()
        listeningLabel.textColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
        listeningLabel.font = UIFont.systemFont(ofSize: 14)
        listeningLabel.text = "Listening"
        return listeningLabel
    }()

    private lazy var speakingLabel: UILabel = {
        let speakingLabel = UILabel()
        speakingLabel.textColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
        speakingLabel.font = UIFont.systemFont(ofSize: 14)
        speakingLabel.text = "Talking"
        speakingLabel.textAlignment = .right
        return speakingLabel
    }()

    private lazy var voiceView: UIView = {
        let voiceView = UIView()
        voiceView.backgroundColor = UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
        voiceView.layer.cornerRadius = 8
        voiceView.layer.masksToBounds = true
        voiceView.addSubview(microphoneImageView)
        voiceView.addSubview(spokenTextLabel)
        return voiceView
    }()

    private lazy var microphoneImageView: UIImageView = {
        let microphoneImageView = UIImageView()
        microphoneImageView.image = UIImage(named: "microphone-pulse-speaking")
        microphoneImageView.contentMode = .scaleAspectFill
        return microphoneImageView
    }()

    private lazy var spokenTextLabel: UILabel = {
        let spokenTextLabel = UILabel()
        spokenTextLabel.textColor = UIColor(red: 0 / 255.0, green: 127.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
        spokenTextLabel.font = UIFont.boldSystemFont(ofSize: 16)
        spokenTextLabel.numberOfLines = 0
        spokenTextLabel.textAlignment = .center
        return spokenTextLabel
    }()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Stop", for: .normal)
        cancelButton.setBackgroundColor(UIColor(red: 0 / 255.0, green: 127.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0), forState: .normal)
        cancelButton.addTarget(for: .touchUpInside) { _ in
            self.dismissView()
        }
        return cancelButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
    }

    @objc func dismissView() {
        dismissCallback?()
        dismiss(animated: true)
    }

    private func setConstraints() {
        view.addSubview(dimcontainerView)
        view.addSubview(backgroundView)

        dimcontainerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        backgroundView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(30)
            make.left.right.equalToSuperview().inset(18)
        }

        shadowView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalToSuperview().inset(32)
            make.height.equalTo(27)
        }

        listeningLabel.snp.makeConstraints { (make) -> Void in
            make.left.top.bottom.equalToSuperview()
        }

        speakingLabel.snp.makeConstraints { (make) -> Void in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(listeningLabel.snp.right).inset(5)
        }

        voiceView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.right.left.equalToSuperview().inset(32)
        }

        microphoneImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(16)
            make.right.left.equalToSuperview()
        }

        spokenTextLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(microphoneImageView.snp.bottom).offset(-32)
            make.right.left.bottom.equalToSuperview().inset(16)
        }

        cancelButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(45)
            make.top.equalTo(voiceView.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(32)
        }
    }

    func changeState(to newState: VoiceState) {
        switch newState {
        case .listening(let suggestion):
            spokenTextLabel.text = suggestion
            spokenTextLabel.textColor = UIColor(red: 0 / 255.0, green: 127.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
            microphoneImageView.image = UIImage(named: "microphone-pulse-speaking")
            listeningLabel.text = "We are listening"
            listeningLabel.textColor = UIColor(red: 0 / 255.0, green: 127.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
            listeningLabel.font = UIFont.boldSystemFont(ofSize: 20)
            speakingLabel.text = "Talking"
            speakingLabel.textColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
            speakingLabel.font = UIFont.systemFont(ofSize: 14)

        case .speaking(let phrase):
            spokenTextLabel.text = phrase
            spokenTextLabel.textColor = UIColor(red: 234.0 / 255.0, green: 105.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
            microphoneImageView.image = UIImage(named: "microphone-pulse-listening")
            listeningLabel.text = "Listening"
            listeningLabel.textColor = UIColor(red: 203.0 / 255.0, green: 203.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
            listeningLabel.font = UIFont.systemFont(ofSize: 14)
            speakingLabel.text = "We are talking"
            speakingLabel.textColor = UIColor(red: 234.0 / 255.0, green: 105.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
            speakingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
    }
}

extension UIButton {
    private class ClosureWrapper<T>: NSObject {
        typealias TargetClosure = (T) -> Void

        let closure: TargetClosure

        init(_ closure: @escaping TargetClosure) {
            self.closure = closure
        }
    }

    public func addTarget(for eventType: UIControl.Event, closure: @escaping (UIControl) -> Void) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: eventType)
    }

    @objc func closureAction() {
        targetClosure?(self)
    }
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: ((UIControl) -> Void)? {
        get {
            let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper<UIControl>
            return closureWrapper?.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper<UIControl>(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func setBackgroundColor(_ color: UIColor, forState status: UIControl.State) {
        let image = self.image(fromColor: color)
        self.setBackgroundImage(image, for: status)
    }

    private func image(fromColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
