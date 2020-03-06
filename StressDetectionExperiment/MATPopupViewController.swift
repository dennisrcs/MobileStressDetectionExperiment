//
//  MATPopupViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/12/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class MATPopupViewController: UIViewController {

    // Question label
    @IBOutlet weak var questionLabel: UILabel!
    
    // Choice buttons
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    @IBOutlet weak var choice3Button: UIButton!
    @IBOutlet weak var choice4Button: UIButton!
    
    var player: AVAudioPlayer?
    
    var dismissTimer: Timer?
    var target: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let asset = NSDataAsset(name:"fail") {
            do {
                player = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                player?.prepareToPlay()
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(AVAudioSession.Category.playback,
                        mode: AVAudioSession.Mode.default,
                        options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                } catch let error {
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        configButtonStyle(choice1Button)
        configButtonStyle(choice2Button)
        configButtonStyle(choice3Button)
        configButtonStyle(choice4Button)
        
        buildQuestion()
        
        dismissTimer = Timer.scheduledTimer(timeInterval: 5, target:self, selector: #selector(MATPopupViewController.dismissPopup), userInfo: nil, repeats: false)
    }
    
    func buildQuestion() {
        let randNum = Int(arc4random_uniform(UInt32(MATs.questions.count)))
        questionLabel.text = MATs.questions[randNum]
        
        var currentAnswers = MATs.answers[randNum]
        target = currentAnswers[0]
        
        currentAnswers.shuffle()
        
        choice1Button.setTitle(currentAnswers[0], for: UIControl.State.normal)
        choice2Button.setTitle(currentAnswers[1], for: UIControl.State.normal)
        choice3Button.setTitle(currentAnswers[2], for: UIControl.State.normal)
        choice4Button.setTitle(currentAnswers[3], for: UIControl.State.normal)
    }
    
    func configButtonStyle(_ button: UIButton!) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    func onChoiceButtonClicked(_ button: UIButton) {
        let buttonAnswer = button.currentTitle
        
        if buttonAnswer != target {
            player?.play()
        }
        
        dismissPopup()
    }
    
    @objc func dismissPopup() {
        dismissTimer?.invalidate()
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name.init("modalIsDismissed"), object: nil)
        }
    }
    
    @IBAction func onClickChoice1Button(_ sender: UIButton) {
        onChoiceButtonClicked(sender)
    }
    
    @IBAction func onClickChoice2Button(_ sender: UIButton) {
        onChoiceButtonClicked(sender)
    }
    
    @IBAction func onClickChoice3Button(_ sender: UIButton) {
        onChoiceButtonClicked(sender)
    }
    
    @IBAction func onClickChoice4Button(_ sender: UIButton) {
        onChoiceButtonClicked(sender)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
