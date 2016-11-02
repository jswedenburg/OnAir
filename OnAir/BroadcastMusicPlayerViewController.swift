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
        sendDataWith(instruction: "play")
    }
    
    func sendPauseData() {
        sendDataWith(instruction: "pause")
    }
    
    func sendNextSongData() {
        SongQueueController.sharedController.addSongToHistoryFromUpNext()
        sendDataWith(instruction: "next")
    }
    
    func sendDataWith(instruction: String){
        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
        let messageDict: [String: Any] = ["instruction": instruction, "song": song.dictionaryRepresentation, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date()]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    func updateViewWithNewSong() {
        let song = SongQueueController.sharedController.upNextQueue[0]
        self.songNameLabel.text = song.name
        self.songArtistLabel.text = song.artist
        
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            self.songAlbumImageView.image = image
        }
    }

}

extension BroadcastMusicPlayerViewController: MusicPlayerControllerNowPlayingDelegate{
    func nowPlayingItemDidChange() {
//        print("I am here you SoB")
//        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
//        MPCManager.sharedController.sendData(dictionary: ["song":song.dictionaryRepresentation])
    }
}
