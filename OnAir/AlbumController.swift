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
    
    func displayAlbumFrom(songsArray: [Song]) -> [Album] {
        var newAlbumArray: [Album] = []
        for song in songsArray {
            let album = Album(albumName: song.albumName, artist: song.artist, collectionID: song.collectionID, albumCover: song.image)
            if newAlbumArray.contains(album) {
                //Do Nothing
            } else {
                newAlbumArray.append(album)
            }
        }
        return newAlbumArray
    }
    
    func addSongsToQueueWith(album: Album) {
        SearchController.fetchAlbumSongsWith(id: album.collectionID) { (songs) in
            guard let songs = songs else { return }
            for song in songs{
                DispatchQueue.main.async {
                    SongQueueController.sharedController.upNextQueue.append(song)
                }
            }
        }
    }
    
    func removeSongsFromQueueFrom(album: Album) {
        let id = album.collectionID
        
        let songs = SongQueueController.sharedController.upNextQueue.filter( { $0.collectionID == id })
        
        for song in songs {
            let index = SongQueueController.sharedController.upNextQueue.index(of: song)
            guard let songIndex = index else { return }
            SongQueueController.sharedController.upNextQueue.remove(at: songIndex)
        }
        
    }
}
