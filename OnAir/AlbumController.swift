//
//  AlbumController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class AlbumController {
    
    static let sharedController = AlbumController()
    
    var albumArray: [Album] = []
    
    func displayAlbumFrom(songsArray: [Song]) {
        
        var newAlbumArray: [Album] = []
        
        for song in songsArray {
            
            let album = Album(albumName: song.albumName, artist: song.artist, collectionID: song.collectionID, albumCover: song.image)
            
            if newAlbumArray.contains(album) {
                print("heeloo")
            } else {
                newAlbumArray.append(album)
                print("Nope")
            }
        }
        self.albumArray = newAlbumArray
        print(self.albumArray)
    }
    
    
}
