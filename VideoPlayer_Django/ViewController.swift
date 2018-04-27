//
//  ViewController.swift
//  VideoPlayer_Django
//
//  Created by 大容 林 on 2018/4/27.
//  Copyright © 2018年 DjangoCode. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let seekDuration: Float64 = 10
    var videoLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isPlaying: Bool! {
        didSet {
            if isPlaying {
                playButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
            } else {
                playButton.setBackgroundImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            }
        }
    }
    var isLandscape = false {
        didSet {
            if isLandscape {
                fullButton.setBackgroundImage(#imageLiteral(resourceName: "full_screen_exit"), for: .normal)
            } else {
                fullButton.setBackgroundImage(#imageLiteral(resourceName: "full_screen_button"), for: .normal)
            }
        }
    }
    var isButtonAlpha = false
    var playerObsever: Any?
    let lValue = UIInterfaceOrientation.landscapeLeft.rawValue
    let pValue = UIInterfaceOrientation.portrait.rawValue
    var centerLabel = UILabel()
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var videoProgressSlider: UISlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullButton: UIButton!
    var buttons = [UIButton]()
    @IBAction func searchURLAction(_ sender: UIButton) {
        if let urlString = searchTextField.text  , urlString != "" {
            if let searchURL = URL(string: searchTextField.text!) {
                playVideoURL(url: searchURL)
            }
        }
    }
    @IBAction func volumeButton(_ sender: UIButton) {
        if let videoPlayer = player {
            if videoPlayer.isMuted {
                videoPlayer.isMuted = false
                sender.setBackgroundImage(#imageLiteral(resourceName: "volume_up"), for: .normal)
            } else {
                videoPlayer.isMuted = true
                sender.setBackgroundImage(#imageLiteral(resourceName: "volume_off"), for: .normal)
            }
        }
    }
    @IBAction func rewindButton(_ sender: Any) {
        if let videoPlayer = player {
            let playerCurrentTime = CMTimeGetSeconds(videoPlayer.currentTime())
            var newTime = playerCurrentTime - seekDuration
            if newTime < 0 {
                newTime = 0
            }
            let cmTimeConvert : CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
            videoPlayer.seek(to: cmTimeConvert, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    @IBAction func playOrPauseButton(_ sender: UIButton) {
        if let videoPlayer = player {
            if isPlaying {
                player?.pause()
                isPlaying = false
            } else {
                player?.play()
                isPlaying = true
            }
        }
    }
    @IBAction func fastForwardButton(_ sender: UIButton) {
        if let videoPlayer = player {
            guard let totalDuration  = videoPlayer.currentItem?.duration else{
                return
            }
            let playerCurrentTime = CMTimeGetSeconds(videoPlayer.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < (CMTimeGetSeconds(totalDuration) - seekDuration) {
                let cmTimeConvert: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
                videoPlayer.seek(to: cmTimeConvert, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            }
        }
    }
    
    @IBAction func fullScreenButton(_ sender: UIButton) {
        if let videoPlayer = player {
            if isLandscape {
                isLandscape = false
                UIDevice.current.setValue(pValue, forKey: "orientation")
            } else {
                isLandscape = true
                UIDevice.current.setValue(lValue, forKey: "orientation")
            }
        }
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if player == nil {
                centerLabel.text = "目前尚無影片可播放"
            } else {
                centerLabel.text = ""
            }
            
            centerView.backgroundColor = UIColor.black
            isLandscape = true
            currentTimeLabel.textColor = UIColor.white
            remainingTimeLabel.textColor = UIColor.white
            self.navigationController?.navigationBar.isHidden = true
            searchTextField.isHidden = true
            searchButton.isHidden = true
            buttons.map({
                $0.tintColor = UIColor.white
            })
        } else {
            centerView.backgroundColor = UIColor.white
            isLandscape = false
            currentTimeLabel.textColor = UIColor.black
            remainingTimeLabel.textColor = UIColor.black
            self.navigationController?.navigationBar.isHidden = false
            searchTextField.isHidden = false
            searchButton.isHidden = false
            isButtonAlpha = false
            buttons.map({
                $0.alpha = 1
                $0.tintColor = UIColor.black
            })
            self.videoProgressSlider.alpha = 1
            self.currentTimeLabel.alpha = 1
            self.remainingTimeLabel.alpha = 1
        }
    }
    override var prefersStatusBarHidden: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    override func viewDidLayoutSubviews() {
        videoLayer?.frame = centerView.bounds
        centerLabel.center = centerView.center
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationColor()
        setupButtons()
        setupGesture()
        setupCenterLabel()
        videoProgressSlider.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func setupCenterLabel()  {
        centerLabel = UILabel(frame: CGRect(x: centerView.center.x, y: centerView.center.y, width: 200, height: 50))
        centerLabel.textColor = UIColor.white
        centerLabel.textAlignment = .center
        self.centerView.addSubview(centerLabel)
    }
    func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        if isLandscape {
            isButtonAlpha = !isButtonAlpha
            if isButtonAlpha {
                for b in buttons {
                    UIView.animate(withDuration: 0.2, animations: {
                        b.alpha = 0
                    })
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.videoProgressSlider.alpha = 0
                    self.currentTimeLabel.alpha = 0
                    self.remainingTimeLabel.alpha = 0
                })
            } else {
                for b in buttons {
                    UIView.animate(withDuration: 0.2, animations: {
                        b.alpha = 1
                    })
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.videoProgressSlider.alpha = 1
                    self.currentTimeLabel.alpha = 1
                    self.remainingTimeLabel.alpha = 1
                })
            }
        }
    }
    func setupButtons()  {
        searchButton.layer.borderColor = UIColor.gray.cgColor
        searchButton.layer.borderWidth = 1
        searchButton.layer.cornerRadius = 3
        searchButton.clipsToBounds = true
        buttons.append(muteButton)
        buttons.append(backButton)
        buttons.append(playButton)
        buttons.append(forwardButton)
        buttons.append(fullButton)
    }
    @objc func onValueChange() {
        if let videoPlayer = self.player {
            let cmTimeConvert: CMTime = CMTimeMake(Int64(self.videoProgressSlider.value * 1000), 1000)
            videoPlayer.seek(to: cmTimeConvert, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    func registObseverToPlayer(change: @escaping (_ time: CMTime)->Void) {
        if let videoPlayer = player {
            let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let mainQueue = DispatchQueue.main
            playerObsever = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { (time) in
                change(time)
            }
        }
    }
    func removeCurrentPlayerObseve (){
        if let videoPlayer = player {
            videoPlayer.removeTimeObserver(playerObsever)
            self.playerObsever = nil
        }
    }
    func setupNavigationColor() {
        self.navigationItem.title = "Video Player"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func playVideoURL(url: URL){
        if videoLayer != nil {
            videoLayer?.removeFromSuperlayer()
        }
        if AVAsset(url: url).isPlayable {
            player = AVPlayer(url: url)
            videoLayer = AVPlayerLayer(player: player)
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoLayer?.frame = centerView.bounds
            centerView.layer.addSublayer(videoLayer!)
            registObseverToPlayer { [weak self] (time) in
                if let videoPlayer = self?.player {
                    let playerCurrentTime = Int(CMTimeGetSeconds(videoPlayer.currentTime()))
                    let totalDurationTime  = Int(CMTimeGetSeconds((videoPlayer.currentItem?.duration)!))
                    let remainTime = totalDurationTime - playerCurrentTime
                    self?.currentTimeLabel.text = playerCurrentTime.asTimeString()
                    self?.remainingTimeLabel.text = remainTime.asTimeString()
                    self?.videoProgressSlider.maximumValue = Float(totalDurationTime)
                    self?.videoProgressSlider.minimumValue = 0
                    self?.videoProgressSlider.value = Float(playerCurrentTime)
                }
            }
            player?.play()
            isPlaying = true
        }
    }
    
}

