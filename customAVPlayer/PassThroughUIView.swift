//
//  PassThroughUIView.swift
//  customAVPlayer
//
//  Created by Steven Curtis on 05/06/2017.
//  Copyright © 2017 Steven Curtis. All rights reserved.
//

import UIKit

class PassThroughUIView: UIView {
    var timer: Timer?
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if !view.isHidden && view.point(inside: self.convert(point, to: view), with: event) {
                view.isHidden = false
                timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
                    for view in self.subviews {
                        view.isHidden = true
                    }
                }
                return true
            }
        }
        for view in subviews {
            view.isHidden = false
        }
        return false
    }    
}
