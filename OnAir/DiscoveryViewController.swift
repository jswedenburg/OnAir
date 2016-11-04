//
//  BroadCastViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class DiscoveryViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var startStopAdvertisingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var broadcastLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let listener = Notification.Name("listenerMP")
    var isConnected = false
    
    
    //View Overriding Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.dataDelegate = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.browser.startBrowsingForPeers()
        MPCManager.isBrowsing = true
        broadcastLabel.adjustsFontSizeToFitWidth = true
        let isBrowsingNotification = Notification.Name(rawValue: "isBrowsingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isBrowsingNotification, object: nil)
        let isAdvertisingNotification = NSNotification.Name(rawValue: "isAdvertisingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isAdvertisingNotification, object: nil)
    }
    
    //IBActions
    @IBAction func broadcastButtonPressed(sender: UIButton) {
        
        if MPCManager.sharedController.isAdvertising {
            startStopAdvertisingButton.setTitle("Start Broadcasting", for: .normal)
            MPCManager.sharedController.advertiser.stopAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = false
            MPCManager.sharedController.disconnect()
            self.tableView.isUserInteractionEnabled = true
            broadcastLabel.text = ""
            
            
        } else {
            startStopAdvertisingButton.setTitle("Stop Broadcasting", for: .normal)
            MPCManager.sharedController.advertiser.startAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = true
            self.tableView.isUserInteractionEnabled = false
            broadcastLabel.text = "YOU ARE DJING BRO"
        }
    }
    
    func advertisingBrowsingIdentify() {
        
        if MPCManager.sharedController.isAdvertising == false {
            MusicPlayerController.sharedController.listenerPause()
            SongQueueController.sharedController.upNextQueue = []
        }
        
        if MPCManager.sharedController.isAdvertising {
            self.tabBarController?.tabBar.backgroundColor = UIColor.red
        } else if MPCManager.isBrowsing {
            self.tabBarController?.tabBar.backgroundColor = UIColor.green
        } else {
            self.tabBarController?.tabBar.backgroundColor = UIColor.white
        }
    }
    
    public func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}




// MARK: - TableView Delegate and Datasource

extension DiscoveryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPCManager.sharedController.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "broadcastCell", for: indexPath) as? DiscoveryTableViewCell
        let peer = MPCManager.sharedController.foundPeers[indexPath.row]
        DispatchQueue.main.async {
            cell?.activityIndicator.hidesWhenStopped = true
            cell?.peerLabel.text = peer.displayName
        }
        return cell ?? DiscoveryTableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let peer = MPCManager.sharedController.foundPeers[indexPath.row] as MCPeerID
        guard let session = MPCManager.sharedController.session else { return }
        let cell = tableView.cellForRow(at: indexPath) as! DiscoveryTableViewCell
        cell.peerLabel.text = peer.displayName
        cell.activityIndicator.startAnimating()
        
        if isConnected == false {
            MPCManager.sharedController.browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
            connectedWithPeer(peerID: peer)
            isConnected = true
        } else {
            MPCManager.sharedController.disconnect()
            broadcastLabel.text = ""
            cell.connectingLabel.text = ""
            isConnected = false
            cell.activityIndicator.stopAnimating()
            MusicPlayerController.sharedController.stop()
            alert(title: "Disconnected", message: "You've been disconnected from \(peer.displayName)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? DiscoveryTableViewCell
        cell?.connectingLabel.text = ""
        cell?.activityIndicator.stopAnimating()
        cell?.activityIndicator.hidesWhenStopped = true
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose or Start a Broadcast"
    }
}

//MPC Manager Delegate
extension DiscoveryViewController: MPCManagerDelegate{
    
    func foundPeer(){
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        if MPCManager.sharedController.isAdvertising == false {
            DispatchQueue.main.async {
                let indexPath = self.tableView.indexPathForSelectedRow
                let cell = self.tableView.cellForRow(at: indexPath!) as? DiscoveryTableViewCell
                cell?.activityIndicator.stopAnimating()
                cell?.activityIndicator.hidesWhenStopped = true
                cell?.connectingLabel.text = "Connected"
                self.parent?.parent?.tabBarController!.selectedIndex = 3
            }
        }
    }
}

extension DiscoveryViewController: GotDataFromBroadcaster{
    func dataReceivedFromBroadcast(data: Data) {
        guard let dictionaryFromData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else { return }
        
        guard let instruction = dictionaryFromData["instruction"] as? String?,
            let songDictionary = dictionaryFromData["song"] as? [String: Any]?,
            let playbacktimeStamp = dictionaryFromData["playbackTime"] as? TimeInterval?,
            let timeStamp = dictionaryFromData["timeStamp"] as? Date? else { return }
        
        if songDictionary != nil {
            guard let songDictionary  = dictionaryFromData["song"] as? [String: Any],
                let song = Song(dictionary: songDictionary) else { return }
            MusicPlayerController.sharedController.setBroadcaterQueueWith(ids: ["\(song.songID)"])
        }
        
        if instruction != nil{
            guard let instruction = instruction else { return }
            switch instruction{
            case "play":
                print("play")
                if timeStamp != nil && playbacktimeStamp != nil{
                    let playbackTime = Date().timeIntervalSince(timeStamp!) + playbacktimeStamp!
                    MusicPlayerController.sharedController.systemPlayer.prepareToPlay()
                    MusicPlayerController.sharedController.setCurrentPlaybackTime(playbackTime)
                }
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
    
    
}
