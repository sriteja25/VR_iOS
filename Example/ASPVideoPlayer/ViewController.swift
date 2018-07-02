//
//  ViewController.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pitis on 06/18/2016.
//  Copyright (c) 2016 Andrei-Sergiu Pitis. All rights reserved.
//

import UIKit
import ASPVideoPlayer
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
	@IBOutlet weak var videoTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoPlayer: ASPVideoPlayerView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTimeField: UITextField!
    
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var videoTimingFrames: UILabel!
    
    @IBOutlet weak var endSlider: UISlider!
    @IBOutlet weak var startSlider: UISlider!
    let firstVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
	let secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")
	
    @IBOutlet weak var videoTimer: UILabel!
    var arrTimers = [String]()
    var rootRef: DatabaseReference!
	override func viewDidLoad() {
		super.viewDidLoad()

        FirebaseApp.configure()
        rootRef = Database.database().reference()
		videoPlayer.videoURL = firstVideoURL
		videoPlayer.gravity = .aspectFit
		videoPlayer.shouldLoop = true
		videoPlayer.startPlayingWhenReady = false
		
		videoPlayer.backgroundColor = UIColor.black
        self.startSlider.maximumValue = Float(videoPlayer.videoLength)
        self.endSlider.maximumValue = Float(videoPlayer.videoLength)
		videoPlayer.newVideo = {
			print("newVideo")
		}
		
		videoPlayer.readyToPlayVideo = {
			print("readyToPlay")
		}
		
		videoPlayer.startedVideo = {
			print("start")
			
		}
        
		
        videoPlayer.finishedVideo = { [weak self] in
            guard let strongSelf = self else { return }
            
			print("finishedVideo")
            if strongSelf.videoPlayer.videoURL == strongSelf.firstVideoURL {
				strongSelf.videoPlayer.startPlayingWhenReady = true
				strongSelf.videoPlayer.videoURL = strongSelf.secondVideoURL
			}
			
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
//                strongSelf.videoTopConstraint.constant = 150.0
//                strongSelf.videoBottomConstraint.constant = 150.0
//                strongSelf.videoLeadingConstraint.constant = 150.0
//                strongSelf.videoTrailingConstraint.constant = 150.0
//                strongSelf.view.layoutIfNeeded()
//                }, completion: { (finished) in
//                    UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn, animations: {
//                        
//                        strongSelf.videoTopConstraint.constant = 0.0
//                        strongSelf.videoBottomConstraint.constant = 0.0
//                        strongSelf.videoLeadingConstraint.constant = 0.0
//                        strongSelf.videoTrailingConstraint.constant = 0.0
//                        
//                        strongSelf.view.layoutIfNeeded()
//                        }, completion: { (finished) in
//                            
//                    })
//            })
		}
		
		videoPlayer.playingVideo = { (progress) -> Void in
            //let progressString = String.localizedStringWithFormat("%.2f", progress)
            let pro = (progress/self.videoPlayer.videoLength) * 100
            let y = Double(round(10*pro)/10)
            let x = Double(round(10*self.videoPlayer.videoLength)/10)
            self.videoTimer.text = "\(y) / \(x)"
            self.slider.value = Float(progress)
            //print("progress: \(progressString) % complete.")
            print(self.videoPlayer.currentTime)
            
		}
        
		videoPlayer.pausedVideo = {
			print("paused")
		}
		
		videoPlayer.stoppedVideo = {
			print("stopped")
		}
		
		videoPlayer.error = { (error) -> Void in
			print("Error: \(error.localizedDescription)")
		}
	}
    
    @IBAction func playerVideo(_ sender: Any) {
        
        videoPlayer.playVideo()
        
    }
    @IBAction func addTimeFrame(_ sender: Any) {
        
        if(startTimeField.text != "" && endTimeField.text != ""){
            
            let f = startTimeField.floatValue()
            let y = Double(round(10*f)/10)
            
            let f2 = endTimeField.floatValue()
            let y2 = Double(round(10*f2)/10)
            
            arrTimers.append("\(y)-\(y2)")
            rootRef.child("Video").child("\(arrTimers.count)").setValue("\(y)-\(y2)")
            getTimerLabel()
        }
        
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func startSliderValueChanged(_ sender: Any) {
        let y = Double(round(10*startSlider.value)/10)
        startTimeField.text = "\(y)"
    }
    
    @IBAction func endSliderValueChanged(_ sender: Any) {
        let y = Double(round(100*endSlider.value)/100)
        endTimeField.text = "\(y)"
    }
    
    @IBAction func pauseVideo(_ sender: Any) {
        videoPlayer.pauseVideo()
    }
    
    func getTimerLabel(){
        
        videoTimingFrames.text = ""
        for i in arrTimers{
            videoTimingFrames.text =  videoTimingFrames.text! + i + "\n"
        }
    }
    
}

extension UITextField {
    func floatValue(locale : Locale = Locale.current) -> Float {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = locale
        
        let nsNumber = numberFormatter.number(from: text!)
        return nsNumber == nil ? 0.0 : nsNumber!.floatValue
    }
}

