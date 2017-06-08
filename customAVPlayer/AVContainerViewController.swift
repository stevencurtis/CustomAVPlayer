//
//  AVContainerViewController.swift
//  customAVPlayer
//
//  Created by Steven Curtis on 04/06/2017.
//  Copyright © 2017 Steven Curtis. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class AVContainerViewController: UIViewController {
    
    //var video = "AppInventorL1TexttoSpeech"
    var video = "Fly - 8262"
    var player: AVPlayer?
    var playstate = false
    var timer: Timer?
    var duration: CMTime?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var lblCurrentText: UILabel!
    @IBOutlet weak var playHeadSlider: UISlider!
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var lblOverallDuration: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var embeddedContainer: UIView!
    
    
    @IBOutlet weak var touchView: UIView!
    
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        if (playstate == false){
            player?.play()
            playstate = true
            playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.audioSliderUpdate), userInfo: nil, repeats: true)
        }
        else {
            player?.pause()
            playstate = false
            playButton.setImage(UIImage(named: "play.png"), for: .normal)
            timer?.invalidate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        player?.pause()
        playstate = false
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        player?.pause()
        playstate = false
        playButton.setImage(UIImage(named: "play.png"), for: .normal)
        timer?.invalidate()
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if (hours != 0 ){
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)}
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        duration = player!.currentItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration!)
        lblOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
        lblRemaining.text = "-" +  self.stringFromTimeInterval(interval: seconds)
        
        playHeadSlider.setThumbImage(UIImage(named: "sliderdot3.png"), for: .normal)
        playHeadSlider.setThumbImage(UIImage(named: "sliderdot3.png"), for: .highlighted)
        playHeadSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchBegin), for: .touchDown)
        playHeadSlider.addTarget(self, action:    #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpInside)
        playHeadSlider.addTarget(self, action: #selector(self.handlePlayheadSliderTouchEnd), for: .touchUpOutside)
        playHeadSlider.addTarget(self, action: #selector(self.handlePlayheadSliderValueChanged), for: .valueChanged)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.audioSliderUpdate), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        playstate = false
        playButton.setImage(UIImage(named: "play.png"), for: .normal)
    }
    
    func audioSliderUpdate() {
        let currentTime : CMTime = (player?.currentTime())!
        let seconds : Float64 = CMTimeGetSeconds(currentTime)
        let time : Float = Float(seconds)
        playHeadSlider.setValue( time.divided(by: Float(CMTimeGetSeconds(duration!))) , animated: false)
        let currentseconds : Float64 = CMTimeGetSeconds(duration!) * Double( Float(seconds / CMTimeGetSeconds(duration!)) )
        lblCurrentText.text = self.stringFromTimeInterval(interval: currentseconds)
        lblRemaining.text = "-" + self.stringFromTimeInterval(interval: CMTimeGetSeconds(duration!)  - currentseconds)
        
    }
    
    @IBAction func handlePlayheadSliderTouchBegin(_ sender: UISlider) {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    @IBAction func handlePlayheadSliderValueChanged(_ sender: UISlider) {
        let currentseconds : Float64 = CMTimeGetSeconds(duration!) * Double(sender.value)
        lblCurrentText.text = self.stringFromTimeInterval(interval: currentseconds)
        lblRemaining.text = "-" + self.stringFromTimeInterval(interval: CMTimeGetSeconds(duration!)  - currentseconds)
    }
    
    @IBAction func handlePlayheadSliderTouchEnd(_ sender: UISlider) {
        let newCurrentTime: TimeInterval = Double (sender.value) * CMTimeGetSeconds(duration!)
        let seekToTime: CMTime = CMTimeMakeWithSeconds(newCurrentTime, 600)
        player?.seek(to: seekToTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.audioSliderUpdate), userInfo: nil, repeats: true)
        if (playstate==false){
            player?.play()
            playstate = true
            playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AVPlayerViewController
        {
            print ("segue")
            guard let path = Bundle.main.path(forResource: video, ofType:"mp4") else {
                debugPrint("video.m4v not found")
                return
            }
            if segue.identifier == "embed" {
                player = AVPlayer(url: URL(fileURLWithPath: path))
                vc.player = player
                vc.showsPlaybackControls = false
                vc.allowsPictureInPicturePlayback = false
            }
        }
    }
}
