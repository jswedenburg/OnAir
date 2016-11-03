//
//  ReceiverMusicPlayerViewController.swift
//  OnAir
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MediaPlayer

class ListenerMusicPlayerViewController: UIViewController, GotDataFromBroadcaster {
    
    //MARK: Outlets
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: IBActions
    
    @IBAction func addSongToLibrary(sender: UIButton) {
        let mediaLibrary = MPMediaLibrary.default()
        if let song = self.song {
            mediaLibrary.addItem(withProductID: String(song.songID), completionHandler: nil)
            print("song added to library")
        }
    }
    
    
    // Will be needing for the broadcaster to send trackID, songName, and artistName.
    var previouslyPlayedSongs: [Song] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var song: Song?{
        didSet{
            //guard let song = oldValue else { return }
            //previouslyPlayedSongs.append(song)
        }
    }
    
    let historyQueueHasChanged = Notification.Name(rawValue: "historyQueueHasChanged")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.dataDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: historyQueueHasChanged, object: nil)
    }
    
    func updateViewWith(song: Song) {
        self.albumNameLabel.text = song.albumName
        self.songNameLabel.text = song.name
        self.artistNameLabel.text = song.artist
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            DispatchQueue.main.async {
                self.albumCoverImageView.image = image
            }
        }
    }
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    func dataReceivedFromBroadcast(data: Data) {
        guard let dictionaryFromData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else { return }
        
        guard let instruction = dictionaryFromData["instruction"] as? String?,
            let songDictionary = dictionaryFromData["song"] as? [String: Any]?,
        let playbacktimeStamp = dictionaryFromData["playbackTime"] as? TimeInterval?,
        let timeStamp = dictionaryFromData["timeStamp"] as? Date? else { return }
        
        if songDictionary != nil {
            guard let songDictionary  = dictionaryFromData["song"] as? [String: Any],
                let song = Song(dictionary: songDictionary) else { return }
            self.song = song
            MusicPlayerController.sharedController.setBroadcaterQueueWith(ids: ["\(song.songID)"])
            updateViewWith(song: song)
        }
        
        if instruction != nil{
            guard let instruction = instruction else { return }
            switch instruction{
            case "play":
                print("play")
                if timeStamp != nil && playbacktimeStamp != nil{
                    let playbackTime = Date().timeIntervalSince(timeStamp!) + playbacktimeStamp! + 0.2
                    MusicPlayerController.sharedController.applicationPlayer.prepareToPlay()
                    MusicPlayerController.sharedController.setCurrentPlaybackTime(playbackTime)
                }
                MusicPlayerController.sharedController.broadcaterPlay()
            case "pause":
                print("pause")
                MusicPlayerController.sharedController.broadcasterPause()
            case "next":
                print("next")
                MusicPlayerController.sharedController.applicationPlayer.prepareToPlay()
                MusicPlayerController.sharedController.setCurrentPlaybackTime(Date().timeIntervalSince(timeStamp!) + playbacktimeStamp! + 0.2)
                MusicPlayerController.sharedController.broadcaterPlay()
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
            return SongQueueController.sharedController.historyQueue.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "previousSongCell", for: indexPath) as? PreviouslyPlayedSongTableViewCell else { return PreviouslyPlayedSongTableViewCell() }
            let song = SongQueueController.sharedController.historyQueue[indexPath.row]
            
            cell.artistNameLabel.text = song.artist
            cell.songNameLabel.text = song.name
            
            return cell
        }
}
