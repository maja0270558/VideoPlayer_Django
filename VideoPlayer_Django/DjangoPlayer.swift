//
//  DjangoPlayer.swift
//  VideoPlayer_Django
//
//  Created by 大容 林 on 2018/4/27.
//  Copyright © 2018年 DjangoCode. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
protocol DjangoPlayerDelegate :class{
    func playerPlayingDidChange(isPlaying: Bool)
    func playerMutedDidChange(isMuted: Bool)
    func playerDidRotate(isLandscape: Bool)
    func playerCurrentTime(currentTime: String, remainingTime: String, currentTimeFloat: Float,totalDurationTime: Float)
}

class DjangoPlayer: AVPlayer {
    weak var delegate: DjangoPlayerDelegate?
    let lValue = UIInterfaceOrientation.landscapeLeft.rawValue
    let pValue = UIInterfaceOrientation.portrait.rawValue
    let seekDuration: Float64 = 10
    var videoLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isPlaying: Bool! = false {
        didSet {
            guard let p = player else {
                return
            }
            delegate?.playerPlayingDidChange(isPlaying: isPlaying)
            if isPlaying {
                p.play()
            } else {
                p.pause()
            }
        }
    }
    var isLandscape = false {
        didSet {
            delegate?.playerDidRotate(isLandscape: isLandscape)
        }
    }
    var nowisMuted: Bool = false {
        didSet{
            guard let p = player else {
                return
            }
            p.isMuted = nowisMuted
            delegate?.playerMutedDidChange(isMuted: p.isMuted)
            
        }
    }
    var playerObsever: Any?
    func rotate(){
        if UIDevice.current.orientation.isLandscape {
            isLandscape = false
            UIDevice.current.setValue(pValue, forKey: "orientation")
        } else {
            isLandscape = true
            UIDevice.current.setValue(lValue, forKey: "orientation")
        }
    }
    func fastForward() {
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
    
    func rewind() {
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
    
    func removeCurrentPlayerObseve (){
        if let videoPlayer = player {
            videoPlayer.removeTimeObserver(playerObsever)
            self.playerObsever = nil
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
    func seekTo(cmTime: CMTime){
        if let videoPlayer = self.player {
            videoPlayer.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    func playVideoURL(url: URL , onView: UIView){
        if videoLayer != nil {
            videoLayer?.removeFromSuperlayer()
        }
        player?.removeTimeObserver(playerObsever)
        if AVAsset(url: url).isPlayable {
            player = AVPlayer(url: url)
            videoLayer = AVPlayerLayer(player: player)
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoLayer?.frame = onView.bounds
            onView.layer.addSublayer(videoLayer!)
            registObseverToPlayer { [weak self] (time) in
                if let videoPlayer = self?.player {
                    if let videoPlayer = self?.player {
                        let playerCurrentTime = Int(CMTimeGetSeconds(videoPlayer.currentTime()))
                        let totalDurationTime  = Int(CMTimeGetSeconds((videoPlayer.currentItem?.duration)!))
                        let remainTime = totalDurationTime - playerCurrentTime
                        let currentTimeString = playerCurrentTime.asTimeString()
                        let remainingTimeString = remainTime.asTimeString()
                        self?.delegate?.playerCurrentTime(currentTime: currentTimeString, remainingTime: remainingTimeString, currentTimeFloat: Float(playerCurrentTime),totalDurationTime: Float(totalDurationTime))
                    }
                }
            }
            player?.play()
            isPlaying = true
        }
    }
}
