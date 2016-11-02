//
//  ReceiverMusicPlayerViewController.swift
//  OnAir
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class ListenerMusicPlayerViewController: UIViewController, GotDataFromBroadcaster {
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // Will be needing for the broadcaster to send trackID, songName, and artistName.
    var previouslyPlayedSongs: [Song] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var song: Song?{
        didSet{
            guard let song = oldValue else { return }
            previouslyPlayedSongs.append(song)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.dataDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        //        NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(notification:)), name: NSNotification.Name(rawValue: "receivedData"), object: nil)
    }
    
    func updateViewWith(song: Song) {
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            DispatchQueue.main.async {
                self.albumCoverImageView.image = image
            }
        }
        
        self.albumNameLabel.text = song.albumName
        self.songNameLabel.text = song.name
        self.artistNameLabel.text = song.artist
    }
    
    func dataReceivedFromBroadcast(data: Data) {
        guard let dictionaryFromData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else { return }
        
        if dictionaryFromData.first?.key == "song"{
            guard let songDictionary  = dictionaryFromData["song"] as? [String: Any],
                let song = Song(dictionary: songDictionary) else { return }
            
            self.song = song
            MusicPlayerController.sharedController.setListenerQueueWith(id: "\(song.songID)")
        }
        
        if dictionaryFromData.first?.key == "instruction"{
            guard let value = dictionaryFromData["instruction"] as? String else { return }
            switch value{
            case "play":
                print("play")
                MusicPlayerController.sharedController.broadcaterPlay()
            case "pause":
                print("pause")
                MusicPlayerController.sharedController.broadcasterPause()
            case "next":
                print("next")
                MusicPlayerController.sharedController.skip()
            default: ()
            }
        }
    }
    
        @IBAction func muteButtonPressed(_ sender: UIButton) {
            if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
                MusicPlayerController.sharedController.listenerPause()
            } else if MusicPlayerController.sharedController.getApplicationPlayerState() == .paused{
                MusicPlayerController.sharedController.listenerPlay()
            }
        }
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    
    extension ListenerMusicPlayerViewController: UITableViewDelegate, UITableViewDataSource{
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return previouslyPlayedSongs.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "previousSongCell", for: indexPath)
            
            
            
            return cell
        }
}
