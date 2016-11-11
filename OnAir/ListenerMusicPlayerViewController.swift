//
//  ReceiverMusicPlayerViewController.swift
//  OnAir
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ListenerMusicPlayerViewController: UIViewController, GotDataFromBroadcaster {
    
    //MARK: Outlets
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: IBActions
    
    @IBAction func addSongToLibrary(sender: UIButton) {
        let mediaLibrary = MPMediaLibrary.default()
        if let song = DataController.sharedController.song {
            mediaLibrary.addItem(withProductID: String(song.songID), completionHandler: nil)
            print("song added to library")
        }
    }
    
    //MARK: Properties
    
    let player = MusicPlayerController.sharedController.systemPlayer
    let historyQueueHasChanged = Notification.Name(rawValue: "historyQueueHasChanged")
    var mainImage: UIImage?
    var animate: Bool = true
    
    //MARK: View Lifecycle Overriding Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.dataDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: historyQueueHasChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearSong), name: Notification.Name(rawValue: "SongHasChanged"), object: nil)
        let disconnectNoti = Notification.Name(rawValue: "diconnected")
        NotificationCenter.default.addObserver(self, selector: #selector(clearSong), name: disconnectNoti, object: nil)
        
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = TeamMusicColor.ourColor
        animateDiscTurn(imageView: albumCoverImageView, duration: 5.0, rotations: 1.0, repetition: 1.0)
    }
    
    //MARK: Helper Functions
    
    
    func updateViewToDefault() {
        self.albumNameLabel.text = "Album Name"
        self.artistNameLabel.text = "Artist Name"
        self.songNameLabel.text = "Song Name"
        self.albumCoverImageView.image = #imageLiteral(resourceName: "disc")
    }
    
    
    func updateViewWith(song: Song) {
        
        DispatchQueue.main.async {
            self.albumNameLabel.text = song.albumName
            self.songNameLabel.text = song.name
            self.artistNameLabel.text = song.artist
            ImageController.imageForURL(imageEndpoint: song.image) { (image) in
                self.albumCoverImageView.image = image
                self.animate = false
            }
        }
    }
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    func clearSong() {
        if DataController.sharedController.song == nil {
            self.albumNameLabel.text = "Album Name"
            self.songNameLabel.text = "Song Name"
            self.artistNameLabel.text = "Artist Name"
            self.albumCoverImageView.image = #imageLiteral(resourceName: "disc")
            self.animate = true
        }
    }
    
    func dataReceivedFromBroadcast(data: Data) {
        MusicPlayerController.sharedController.systemPlayer.endGeneratingPlaybackNotifications()
        guard let dictionaryFromData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else { return }
        
        guard let instruction = dictionaryFromData["instruction"] as? String?,
            let songDictionary = dictionaryFromData["song"] as? [String: Any]?,
            let playbacktimeStamp = dictionaryFromData["playbackTime"] as? TimeInterval?,
            let timeStamp = dictionaryFromData["timeStamp"] as? Date? else { return }
        
        if songDictionary != nil {
            guard let songDictionary  = dictionaryFromData["song"] as? [String: Any],
                let song = Song(dictionary: songDictionary) else { return }
            MusicPlayerController.sharedController.setBroadcaterQueueWith(ids: ["\(song.songID)"])
            updateViewWith(song: song)
            
            if !SongQueueController.sharedController.historyQueue.contains(song){
                SongQueueController.sharedController.historyQueue.append(song)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if instruction != nil{
            guard let instruction = instruction else { return }
            switch instruction{
            case "play":
                print("play")
                if timeStamp != nil && playbacktimeStamp != nil{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        MusicPlayerController.sharedController.setCurrentPlaybackTime(Date().timeIntervalSince(timeStamp!) + playbacktimeStamp! + 0.4)
                    })
                }
                MusicPlayerController.sharedController.timeWhenPaused = nil
                MusicPlayerController.sharedController.broadcaterPlay()
            case "pause":
                print("pause")
                MusicPlayerController.sharedController.broadcasterPause()
            case "next":
                print("next")
                MusicPlayerController.sharedController.timeWhenPaused = nil
                MusicPlayerController.sharedController.setCurrentPlaybackTime(Date().timeIntervalSince(timeStamp!) + playbacktimeStamp! + 0.1)
                MusicPlayerController.sharedController.broadcaterPlay()
            case "stop":
                print("stop")
                MusicPlayerController.sharedController.stop()
            default: ()
            }
        }
        MusicPlayerController.sharedController.systemPlayer.beginGeneratingPlaybackNotifications()
    }
    
}


//MARK: Tableview Datasource and Delegate
extension ListenerMusicPlayerViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SongQueueController.sharedController.historyQueue.count <= 1 {
            return 0
        } else {
            return SongQueueController.sharedController.historyQueue.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSongCell", for: indexPath) as? PreviouslyPlayedSongTableViewCell
        
        let song = SongQueueController.sharedController.historyQueue.reversed()[indexPath.row + 1]
        
        cell?.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.96])
        cell?.layer.frame = CGRect(x: 20, y: 10, width: self.view.frame.size.width - 20 , height: 86)
        cell?.layer.masksToBounds = true
        cell?.layer.cornerRadius = 10.0
        cell?.layer.shadowOffset = CGSize(width: -1, height: 1)
        cell?.layer.shadowOpacity = 0.5
        
        cell?.updateCellWith(songName: song.name, artistName: song.artist)
        
        return cell ?? PreviouslyPlayedSongTableViewCell()
    }
    
    func animateDiscTurn(imageView: UIImageView, duration: Float, rotations: Float, repetition: Float){
        if animate{
            let rotaionAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
            let value = Float.pi * 2.0 * rotations * duration
            rotaionAnimation.toValue = NSNumber.init(value: value)
            rotaionAnimation.duration = CFTimeInterval(duration)
            rotaionAnimation.isCumulative = true
            rotaionAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            rotaionAnimation.repeatCount = repetition
            
            imageView.layer.add(rotaionAnimation, forKey: "rotationAnimation")
        }
    }
}
