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
    let player = MusicPlayerController.sharedController.systemPlayer
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.sharedController.connectedDelegate = self
        let songHasChanged = Notification.Name(rawValue: "SongHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewWithNewSong), name: songHasChanged, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViewWithNewSong()
        self.tableView.reloadData()
    }
    
    
    //MARK: Actions
    @IBAction func playButtonPressed(){
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            DataController.sharedController.sendPauseData()
        } else {
            DataController.sharedController.sendPlayData()
        }
    }
    
    @IBAction func nextButtonPressed() {
        if SongQueueController.sharedController.upNextQueue.count == 1 {
            DataController.sharedController.sendStopData()
            SongQueueController.sharedController.upNextQueue = []
            alert(title: "Out of songs!", message: "Add more songs to the queue to keep listening")
        } else {
            SongQueueController.sharedController.upNextQueue.remove(at: 0)
            DataController.sharedController.sendPlayData()
        }
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
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
}
