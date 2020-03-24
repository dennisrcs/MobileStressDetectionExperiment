//
//  WritingTaskController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/10/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit
import Dispatch

class WritingTaskController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wordsLeftLabel: UILabel!
    @IBOutlet weak var pinchLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!

    var originalImageWidth: CGFloat = CGFloat(0.0)
    var originalImageHeight: CGFloat = CGFloat(0.0)
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var MATTimer: Timer?
    var taskTimer: Timer?
    var progressBarTimer:Timer?
    
    let roundIntervalDuration: TimeInterval = 20.0
    let taskDuration: TimeInterval = 30.0
    var currentImageNumber:Int = 0
    var sessionNumber:Int = 0
    var elapsedTime:Double = 0
    var easyOrHard:String = ""
    var isEasy:Bool = false
    
    let defaults = UserDefaults.standard
    
    var start:DispatchTime?
    var end:DispatchTime?
    var elapsedTaskTime:Double = 0
    
    var cameraRecorder: CameraRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WritingTaskController.modalDismissed),
                                               name: NSNotification.Name.init("modalIsDismissed"),
                                               object: nil)
        
        cameraRecorder = CameraRecorder()
        
        submitButton.alpha = 0.5
        
        // Adding tap gesture to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let isEasyFirst = defaults.bool(forKey: "isEasyFirst")
        let round = defaults.integer(forKey: "round")
        sessionNumber = defaults.integer(forKey: "sessionNumber")
        
        isEasy = ((isEasyFirst && round == 2) || (!isEasyFirst && round == 4))
        easyOrHard = (isEasy) ? "easy" : "hard"
        
        // Loading text placeholders
        let key:String = "text_session\(sessionNumber)_\(easyOrHard)"
        
        defaults.set("", forKey: "\(key)1")
        defaults.set("", forKey: "\(key)2")
        defaults.set("", forKey: "\(key)3")
        
        var _ = Paintings.init()
        
        loadNextImage()
        
        // Saving the original's image dimensions
        originalImageWidth = imageView.frame.size.width
        originalImageHeight = imageView.frame.size.height
        
        // Configuring text view properties
        textArea.layer.borderColor = UIColor.black.cgColor
        textArea.layer.borderWidth = 1.0
        textArea.layer.cornerRadius = 5.0

        // Assigning delegate to text area component
        textArea.delegate = self
        
        // Adding pinch gesture to image
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.onPinchGesture))
        imageView.addGestureRecognizer(pinchGesture)
        
        // Handling keyboard move up
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if !isEasy {
            MATTimer = Timer.scheduledTimer(timeInterval: roundIntervalDuration, target:self, selector: #selector(WritingTaskController.openMATpopup), userInfo: nil, repeats: false)
        }
        
        progressBarTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(WritingTaskController.updateProgressBar), userInfo: nil, repeats: true)
        
        taskTimer = Timer.scheduledTimer(timeInterval: taskDuration, target:self, selector: #selector(WritingTaskController.wrapupTask), userInfo: nil, repeats: false)
        
        let participandId = defaults.string(forKey: "participantId")!
        cameraRecorder.startRecording("WritingTask_\(participandId)_\(sessionNumber)_\(easyOrHard)")
        
        start = DispatchTime.now()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func updateProgressBar() {
        elapsedTime += 0.1
        progressBar.progress = 1.0 - Float(elapsedTime) / Float(taskDuration)
        
        if elapsedTime >= taskDuration {
            progressBarTimer?.invalidate()
        }
    }
    
    func loadNextImage() {
        currentImageNumber += 1
        
        if currentImageNumber <= 3 {
            let sessionImagePath = "session\(sessionNumber)_\(easyOrHard)\(currentImageNumber)"
            let imageName:String = Paintings.paintings[sessionImagePath]!
            imageView.image = UIImage(named: imageName)
        } else {
            wrapupTask()
        }
    }
    
    @objc func wrapupTask() {
        MATTimer?.invalidate()
        taskTimer?.invalidate()
        
        cameraRecorder.stopRecording()
        
        let text:String = self.textArea.text
        let key:String = "text_session\(self.sessionNumber)_\(self.easyOrHard)\(self.currentImageNumber)"
        self.defaults.set(text, forKey: key)
        
        let round = defaults.integer(forKey: "round")
        defaults.set(round + 1, forKey: "round")
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelfReportViewController") as! SelfReportViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    @objc func modalDismissed() {
        let timeRemaining = taskDuration - TimeInterval(elapsedTaskTime)
        
        taskTimer = Timer.scheduledTimer(timeInterval: timeRemaining, target:self, selector: #selector(WritingTaskController.wrapupTask), userInfo: nil, repeats: false)
        
        progressBarTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(WritingTaskController.updateProgressBar), userInfo: nil, repeats: true)
        
        MATTimer = Timer.scheduledTimer(timeInterval: self.roundIntervalDuration, target:self, selector: #selector(WritingTaskController.openMATpopup), userInfo: nil, repeats: false)
        
        start = DispatchTime.now()
    }
    
    @objc func openMATpopup() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MATPopupViewController") as! MATPopupViewController
        
        end = DispatchTime.now()
        elapsedTaskTime = elapsedTime + calculateElapsedTime()
        
        taskTimer?.invalidate()
        progressBarTimer?.invalidate()
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func calculateElapsedTime() -> Double {
        let nanoTime = (end?.uptimeNanoseconds)! - (start?.uptimeNanoseconds)!
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        return timeInterval
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height + 10
        } else {
            view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
        
            switch sender.state {
            case .changed:
                let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                          y: sender.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                                                .scaledBy(x: sender.scale, y: sender.scale)
                                                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                sender.scale = 1.0
                
            case .ended:
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }
        }
    }
    
    @IBAction func onClickSubmitText(_ sender: Any) {
        let alert = UIAlertController(title: "Submit text?", message: "Are you sure you want to submit the text?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            let text:String = self.textArea.text
            
            let key:String = "text_session\(self.sessionNumber)_\(self.easyOrHard)\(self.currentImageNumber)"
            self.defaults.set(text, forKey: key)
            
            self.loadNextImage()
            
            self.textArea.text = ""
            self.wordsLeftLabel.text = "200 words left"
            self.submitButton.alpha = 0.5
            self.submitButton.isEnabled = false
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getWordsNumber(_ text:String) -> Int {
        let components = text.components(separatedBy: .whitespacesAndNewlines)
        let words = components.filter { !$0.isEmpty }
        let wordsNumber = words.count

        return wordsNumber
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        let text:String = textView.text!
        let wordsNumber:Int = getWordsNumber(text)
        
        if wordsNumber >= 200 {
            wordsLeftLabel.text = "0 words left"
            submitButton.alpha = 1.0
            submitButton.isEnabled = true
        } else {
            wordsLeftLabel.text = "\(200 - wordsNumber) words left"
            submitButton.alpha = 0.5
            submitButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
