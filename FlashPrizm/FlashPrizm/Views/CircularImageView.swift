//
//  CircularImageView.swift
//  FlashPrizm
//
//  Created by HowardWu on 3/19/23.
//

import UIKit

class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
    }
    
}
