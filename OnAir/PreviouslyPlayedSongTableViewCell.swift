//
//  PreviouslyPlayedSongTableViewCell.swift
//  OnAir
//
//  Created by Angel Contreras on 10/27/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class PreviouslyPlayedSongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    func updateCellWith(songName: String, artistName: String){
        songNameLabel.text = songName
        artistNameLabel.text = artistName
    }

}
