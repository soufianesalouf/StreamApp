//
//  PlaylistCVCell.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 4/2/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import UIKit

class PlaylistCVCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var playlistNameLbl: UILabel!
    @IBOutlet weak var playlistDescriptionLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    func configureCell(playlist: Playlist){
        playlistNameLbl.text = playlist.playlistName
        playlistDescriptionLbl.text = playlist.playlistDescription
    }
    
}
