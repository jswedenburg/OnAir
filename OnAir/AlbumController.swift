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
    
    func addSongsToQueueWith(album: Album) {
        fetchAlbumSongsWith(id: album.collectionID) { (songs) in
            guard let songs = songs else { return }
            for song in songs{
                SongQueueController.sharedController.upNextQueue.append(song)
            }
        }
    }
    
    let baseURL = URL(string: "https://itunes.apple.com/lookup")
    //static let endpoint = baseURL?.appendingPathExtension("json")
    
    func fetchAlbumSongsWith(id: Int, completion: @escaping (_ songs: [Song]?)-> Void) {
        
        let urlParameters = ["id":"\(id)", "entity":"song"]
        
        guard let url = baseURL else { completion(nil) ; return }
        
        //call networkcontroller to get data from URL
        NetworkController.performRequest(for: url, httpMethodString: "GET", urlParameters: urlParameters) { (data, error) in
            
            
            //unwrap the data
            guard let data = data else {
                print("Error: no data returned from network")
                completion(nil)
                return
            }
            print(data)
            
            //check if error occurred
            if error != nil {
                print(error?.localizedDescription)
                completion(nil)
            }
            
            //no error but data returned, serialize the JSON data returned
            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: AnyObject],
                let resultsArrayOfDict = jsonDictionary["results"] as? [[String: AnyObject]]
                else {
                    print("Error: Unable to serialize returned JSON data.")
                    completion(nil)
                    return
            }
            
            let songsArray = resultsArrayOfDict.flatMap{Song(dictionary: $0)}
            completion(songsArray)
            
        }
    }
}
