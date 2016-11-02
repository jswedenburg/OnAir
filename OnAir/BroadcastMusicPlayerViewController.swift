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
        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
        let messageDict: [String: Any] = ["instruction": "play", "song": song.dictionaryRepresentation, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date()]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    func sendPauseData() {
        let messageDict: [String: String] = ["instruction": "pause"]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    func sendNextSongData() {
        let messageDict: [String: String] = ["instruction": "next"]
        SongQueueController.sharedController.addSongToHistoryFromUpNext()
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }

}

extension BroadcastMusicPlayerViewController: MusicPlayerControllerNowPlayingDelegate{
    func nowPlayingItemDidChange() {
//        print("I am here you SoB")
//        guard let song = SongQueueController.sharedController.upNextQueue.first else { return }
//        MPCManager.sharedController.sendData(dictionary: ["song":song.dictionaryRepresentation])
    }
}
