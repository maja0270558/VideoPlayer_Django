//
//  TimeExtention.swift
//  VideoPlayer_Django
//
//  Created by 大容 林 on 2018/4/27.
//  Copyright © 2018年 DjangoCode. All rights reserved.
//

import Foundation
struct TimeParts: CustomStringConvertible {
    var seconds = 0
    var minutes = 0
    var description: String {
        return NSString(format: "%02d:%02d", minutes, seconds) as String
    }
}

let EmptyTimeParts = 0.toTimeParts()

extension Int {
    func toTimeParts() -> TimeParts {
        let seconds = self
        var mins = 0
        var secs = seconds
        if seconds >= 60 {
            mins = Int(seconds / 60)
            secs = seconds - (mins * 60)
        }
        
        return TimeParts(seconds: secs, minutes: mins)
    }
    
    func asTimeString() -> String {
        return toTimeParts().description
    }
}
