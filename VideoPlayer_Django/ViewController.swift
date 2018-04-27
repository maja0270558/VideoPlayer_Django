//
//  ViewController.swift
//  VideoPlayer_Django
//
//  Created by 大容 林 on 2018/4/27.
//  Copyright © 2018年 DjangoCode. All rights reserved.
//

import UIKit
import AVFoundation
extension ViewController: DjangoPlayerDelegate {
    func playerPlayingDidChange(isPlaying: Bool) {
        if isPlaying {
            playButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
        } else {
            playButton.setBackgroundImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        }
    }
    
    func playerMutedDidChange(isMuted: Bool) {
        if isMuted {
            muteButton.setBackgroundImage(#imageLiteral(resourceName: "volume_off"), for: .normal)
        } else {
            muteButton.setBackgroundImage(#imageLiteral(resourceName: "volume_up"), for: .normal)
        }
    }
    
    func playerDidRotate(isLandscape: Bool) {
        if isLandscape {
            fullButton.setBackgroundImage(#imageLiteral(resourceName: "full_screen_exit"), for: .normal)
        } else {
            fullButton.setBackgroundImage(#imageLiteral(resourceName: "full_screen_button"), for: .normal)
        }
    }
    
    func playerCurrentTime(currentTime: String, remainingTime: String, currentTimeFloat: Float,totalDurationTime: Float) {
        self.currentTimeLabel.text = currentTime
        self.remainingTimeLabel.text = remainingTime
        self.videoProgressSlider.maximumValue = totalDurationTime
        self.videoProgressSlider.minimumValue = 0
        self.videoProgressSlider.value = currentTimeFloat
    }
    
    
}
class ViewController: UIViewController {
    var myPlayer: DjangoPlayer = DjangoPlayer()
    var isButtonAlpha = false
    var centerLabel = UILabel()
    var buttons = [UIButton]()
    
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
    @IBAction func searchURLAction(_ sender: UIButton) {
        if let urlString = searchTextField.text  , urlString != "" {
            if let searchURL = URL(string: searchTextField.text!) {
                myPlayer.playVideoURL(url: searchURL, onView: centerView)
            }
        }
    }
    @IBAction func volumeButton(_ sender: UIButton) {
        myPlayer.nowisMuted = !myPlayer.nowisMuted
    }
    @IBAction func rewindButton(_ sender: Any) {
        myPlayer.rewind()
    }
    @IBAction func playOrPauseButton(_ sender: UIButton) {
        myPlayer.isPlaying = !myPlayer.isPlaying
    }
    @IBAction func fastForwardButton(_ sender: UIButton) {
        myPlayer.fastForward()
    }
    @IBAction func fullScreenButton(_ sender: UIButton) {
        myPlayer.rotate()
    }
    override func viewDidLayoutSubviews() {
        myPlayer.videoLayer?.frame = centerView.bounds
        centerLabel.center = centerView.center
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationColor()
        setupButtons()
        setupGesture()
        setupCenterLabel()
        setupSliderTarget()
        myPlayer.delegate = self
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if myPlayer.player == nil {
                centerLabel.text = "目前尚無影片可播放"
            } else {
                centerLabel.text = ""
            }
            centerView.backgroundColor = UIColor.black
            currentTimeLabel.textColor = UIColor.white
            remainingTimeLabel.textColor = UIColor.white
            myPlayer.isLandscape = true
            self.navigationController?.navigationBar.isHidden = true
            searchTextField.isHidden = true
            searchButton.isHidden = true
            buttons.map({
                $0.tintColor = UIColor.white
            })
        } else {
            centerView.backgroundColor = UIColor.white
            currentTimeLabel.textColor = UIColor.black
            remainingTimeLabel.textColor = UIColor.black
            myPlayer.isLandscape = false
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
    func setupSliderTarget(){
        videoProgressSlider.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
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
        if  myPlayer.isLandscape {
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
        let cmTimeConvert: CMTime = CMTimeMake(Int64(self.videoProgressSlider.value * 1000), 1000)
        myPlayer.seekTo(cmTime: cmTimeConvert)
    }
    
    func setupNavigationColor() {
        self.navigationItem.title = "Video Player"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
    }
}

