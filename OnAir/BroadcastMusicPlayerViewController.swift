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
    var playMode = true
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.connectedDelegate = self
        MusicPlayerController.sharedController.nowPlayingDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViewWithNewSong()
        self.tableView.reloadData()
    }
    
    
    //MARK: Actions
    @IBAction func playButtonPressed(){
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            MusicPlayerController.sharedController.broadcasterPause()
            sendPauseData()
        } else {
            MusicPlayerController.sharedController.broadcaterPlay()
            sendPlayData()
        }
    }
    
    @IBAction func nextButtonPressed() {
        MusicPlayerController.sharedController.skip()
        sendNextSongData()
    }
    
    func connectedPeersChanged() {
        self.tableView.reloadData()
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
    func sendPlayData() {
        makeDataDictionary(instruction: "play") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData)
        }
    }
    
    func sendPauseData() {
        makeDataDictionary(instruction: "pause") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData)
        }
    }
    
    func sendNextSongData() {
        SongQueueController.sharedController.addSongToHistoryFromUpNext()
        makeDataDictionary(instruction: "next") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData)
        }
    }
    
    func makeDataDictionary(instruction: String, completion: (_ messageDict: [String: Any]?)-> Void){
        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
        let messageDict: [String: Any] = ["instruction": instruction, "song": song.dictionaryRepresentation, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date()]
        
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
}

// MARK: - MusicPlayerController Delegate

extension BroadcastMusicPlayerViewController: MusicPlayerControllerNowPlayingDelegate{
    func nowPlayingItemDidChange() {
//        print("I am here you SoB")
//        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
//        MPCManager.sharedController.sendData(dictionary: ["song":song.dictionaryRepresentation])
    }
}

// MARK: - MPC Manager Delegate
extension BroadcastMusicPlayerViewController: MPCManagerDelegate{
    func foundPeer() {
    }
    
    func lostPeer() {
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        print("New Peer")
        
        var instruction = ""
        
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            instruction = "pause"
        } else {
            instruction = "play"
        }
        
        makeDataDictionary(instruction: instruction) { (messageData) in
            let dataToSend = NSKeyedArchiver.archivedData(withRootObject: messageData)
            
            do {
                try MPCManager.sharedController.session.send(dataToSend, toPeers: [peerID], with: .reliable)
            } catch {
                print("Sending Failed")
            }
        }
        
    }
}
