//
//  SongQueueTableViewCell.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SongQueueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var albumTextLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCellWith(song: Song) {
        self.titleLabel.text = song.name
        self.subtitleLabel.text = song.artist
        self.albumTextLabel?.text = song.albumName
        
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            guard let image = image else { print("Error getting image"); return }
            DispatchQueue.main.async {
                self.albumCoverImage.image = image
            }
        }
    }
    
    func updateCellWith(album: Album) {
        self.titleLabel.text = album.albumName
        self.subtitleLabel.text = album.artist
        self.albumTextLabel = nil
        
        ImageController.imageForURL(imageEndpoint: album.albumCover) { (image) in
            guard let image = image else { print("Error getting image"); return }
            DispatchQueue.main.async {
                self.albumCoverImage.image = image
            }
        }
    }
    
}
