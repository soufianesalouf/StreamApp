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
    
    func configureStationCell(title: String){
        trackTitle.text = title
    }
}
