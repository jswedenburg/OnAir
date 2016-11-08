//
//  BroadcastMediaPlayerViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class BroadcastMusicPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectedPeerArrayChangedDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var songAlbumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    
    //MARK: Properties
    var song: Song?
    let player = MusicPlayerController.sharedController.systemPlayer
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.connectedDelegate = self
        MusicPlayerController.sharedController.systemPlayer.beginGeneratingPlaybackNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViewWithNewSong()
        self.tableView.reloadData()
        
        if MPCManager.sharedController.isAdvertising {
            NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
            
        } else {
            
        }
    }
    
    
    //MARK: Actions
    @IBAction func playButtonPressed(){
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            sendPauseData()
            MusicPlayerController.sharedController.broadcasterPause()
        } else {
            
            sendPlayData()
            MusicPlayerController.sharedController.broadcaterPlay()
            
            
        }
        
        
    }
    
    @IBAction func nextButtonPressed() {
        player.endGeneratingPlaybackNotifications()
        
        sendNextSongData()
        
        MusicPlayerController.sharedController.skip()
        if MusicPlayerController.sharedController.getApplicationPlayerState() != .playing{
            MusicPlayerController.sharedController.broadcaterPlay()
        }
        player.beginGeneratingPlaybackNotifications()
    }
    
    func connectedPeersChanged() {
        self.tableView.reloadData()
        sendDataToNew(peer: MPCManager.sharedController.connectedPeers.last)
    }
    
    //MARK TableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPCManager.sharedController.connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        let peer = MPCManager.sharedController.connectedPeers[indexPath.row]
        cell.textLabel?.text = peer.displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Listening Peers"
    }
    
    
    //MARK: Helper Functions
    //    func handleBroadcastInteraction(notification: Notification) {
    //
    //        if MPCManager.sharedController.isAdvertising{
    //            switch player.playbackState {
    //            case .paused:
    //
    //                    MusicPlayerController.sharedController.broadcasterPause()
    //                    sendPauseData()
    //
    //
    //            case .playing:
    //
    //                    MusicPlayerController.sharedController.broadcaterPlay()
    //                    sendPlayData()
    //
    //            case .interrupted:
    //                MusicPlayerController.sharedController.broadcasterPause()
    //                sendPauseData()
    //            default:
    //                print("broadcaster did something else")
    //            }
    //        }
    //    }
    
    func sendPlayData() {
        makeDataDictionary(instruction: "play") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
    
    func sendPauseData() {
        makeDataDictionary(instruction: "pause") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
    
    func sendNextSongData() {
        makeDataDictionary(instruction: "next") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
        
    }
    
    func makeDataDictionary(instruction: String, completion: (_ messageDict: [String: Any]?)-> Void){
        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
        let messageDict: [String: Any] = ["instruction": instruction, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date(), "song": song.dictionaryRepresentation]
        
        completion(messageDict)
    }
    
    func updateViewWithNewSong() {
        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
        self.songNameLabel.text = song.name
        self.songArtistLabel.text = song.artist
        
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            self.songAlbumImageView.image = image
        }
    }
    
    func sendDataToNew(peer: MCPeerID?){
        guard let peerID = peer else { return }
        print("new peer \(peerID.displayName)")
        var instruction = ""
        
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            instruction = "play"
        } else {
            instruction = "pause"
        }
        makeDataDictionary(instruction: instruction) { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: [peerID])
        }
    }
    
    var didChange: Bool = false
    
    func nowPlayingItemChanged(){
        SongQueueController.sharedController.addSongToHistoryFromUpNext()
        updateViewWithNewSong()
        
        var instruction = ""
        (MusicPlayerController.sharedController.getApplicationPlayerState() == .playing) ? (instruction = "play") : (instruction = "pause")
        
        makeDataDictionary(instruction: instruction) { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
}
