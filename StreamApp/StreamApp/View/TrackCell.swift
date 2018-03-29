//
//  TrackCell.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 3/27/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var nowPlayingAnimationImageView: UIImageView!
    
    func configureStationCell(title: String){
        trackTitle.text = title
//        createNowPlayingAnimation()
//        startNowPlayingAnimation(true)
    }
    
    func createNowPlayingAnimation() {
        nowPlayingAnimationImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingAnimationImageView.animationDuration = 0.7
    }
    
    func startNowPlayingAnimation(_ animate: Bool) {
        animate ? nowPlayingAnimationImageView.startAnimating() : nowPlayingAnimationImageView.stopAnimating()
    }
}
