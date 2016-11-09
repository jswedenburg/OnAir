//
//  BroadcastMediaPlayerViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MediaPlayer

class BroadcastMusicPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectedPeerArrayChangedDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var songAlbumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    
    //MARK: Properties
    let player = MusicPlayerController.sharedController.systemPlayer
    let commandCenter = MPRemoteCommandCenter.shared()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.connectedDelegate = self
        let songHasChanged = Notification.Name(rawValue: "SongHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewWithNewSong), name: songHasChanged, object: nil)
        configureCommandCenter()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViewWithNewSong()
        self.tableView.reloadData()
    }
    
    func configureCommandCenter() {
        self.commandCenter.playCommand.addTarget { (play) -> MPRemoteCommandHandlerStatus in
            DataController.sharedController.sendPlayData()
            MusicPlayerController.sharedController.broadcaterPlay()
            return .success
        }
        
        self.commandCenter.pauseCommand.addTarget { (pause) -> MPRemoteCommandHandlerStatus in
            DataController.sharedController.sendPauseData()
            MusicPlayerController.sharedController.broadcasterPause()
            return .success
        }
        
        self.commandCenter.nextTrackCommand.addTarget { (next) -> MPRemoteCommandHandlerStatus in
            DataController.sharedController.sendNextSongData()
            MusicPlayerController.sharedController.skip()
            return .success
        }
    }
    
    
    //MARK: Actions
    @IBAction func playButtonPressed(){
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            DataController.sharedController.sendPauseData()
            MusicPlayerController.sharedController.broadcasterPause()
        } else {
            DataController.sharedController.sendPlayData()
            MusicPlayerController.sharedController.broadcaterPlay()
        }
    }
    
    @IBAction func nextButtonPressed() {
        DataController.sharedController.sendNextSongData()
        MusicPlayerController.sharedController.skip()
        if MusicPlayerController.sharedController.getApplicationPlayerState() != .playing{
            MusicPlayerController.sharedController.broadcaterPlay()
        }
    }
    
    func connectedPeersChanged(peerID: MCPeerID) {
        self.tableView.reloadData()
        DataController.sharedController.sendDataToNew(peer: peerID)
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
    
    func updateViewWithNewSong() {
        guard let song = DataController.sharedController.song else { return }
        self.songNameLabel.text = song.name
        self.songArtistLabel.text = song.artist
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            self.songAlbumImageView.image = image
        }
    }
    
    var didChange: Bool = false
    var index = 0
    var timeStamp = Date()
    
    
}
