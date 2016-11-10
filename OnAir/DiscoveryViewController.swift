//
//  BroadCastViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ClearSongAfterDisconnectDelegate {
    func getRidOfThatSong()
}


// MARK: Todo - clean up cell's "connected" label. not using it anymore.

class DiscoveryViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var startStopAdvertisingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var micImage: UIImageView!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let listener = Notification.Name("listenerMP")
    var previousCellIndexPath: IndexPath?
    var isConnected = false
    var connectedSessionIndexPath: IndexPath?
    let disconnectNotification = Notification.Name(rawValue: "DisconnectedFromSession")
    static var clearSongDelegate: ClearSongAfterDisconnectDelegate?
    var selectedIndexPath: IndexPath?
    var mainImageImage: UIImage?
    
    //View Overriding Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.dataDelegate = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.browser.startBrowsingForPeers()
        MPCManager.isBrowsing = true
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
            turnOn(MPCManager.sharedController.isAdvertising)
            
            
            
        } else {
            startStopAdvertisingButton.setTitle("Stop Broadcasting", for: .normal)
            MPCManager.sharedController.advertiser.startAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = true
            self.tableView.isUserInteractionEnabled = false
            turnOn(MPCManager.sharedController.isAdvertising)
            
        }
    }
    
    @IBAction func disconnectButtonPressed(_ sender: AnyObject) {
        MPCManager.sharedController.disconnect()
        MusicPlayerController.sharedController.stop()
        NotificationCenter.default.post(name: disconnectNotification, object: nil)
        isConnected = false
        
        MPCManager.sharedController.browser.startBrowsingForPeers()
        DiscoveryViewController.clearSongDelegate?.getRidOfThatSong()
        alert(title: "Disconnected", message: "You've been disconnected from your broadcast")
    }
    
    
    func advertisingBrowsingIdentify() {
        
        if MPCManager.sharedController.isAdvertising == false {
            MusicPlayerController.sharedController.listenerPause()
            SongQueueController.sharedController.upNextQueue = []
        }
        
        
    }
    
    func turnOn(_ bool: Bool){
        UIView.animate(withDuration: 0.8) {
            if bool {
                self.micImage.image = #imageLiteral(resourceName: "MicOn")
            } else {
                self.micImage.image = #imageLiteral(resourceName: "MicOff")
            }
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
        self.selectedIndexPath = indexPath
        
        
        
        switch isConnected {
        case true:
            if indexPath == previousCellIndexPath {
                MPCManager.sharedController.disconnect()
                
                isConnected = false
                cell.activityIndicator.stopAnimating()
                cell.connectingLabel.text = ""
                MusicPlayerController.sharedController.stop()
                NotificationCenter.default.post(name: disconnectNotification, object: nil)
                MPCManager.sharedController.browser.startBrowsingForPeers()
                DiscoveryViewController.clearSongDelegate?.getRidOfThatSong()
                alert(title: "Disconnected", message: "You've been disconnected from \(peer.displayName)")
                cell.isHighlighted = false
                self.tableView.reloadData()
            } else {
                cell.activityIndicator.startAnimating()
                DispatchQueue.main.async {
                    MPCManager.sharedController.disconnect()
                }
                
                MPCManager.sharedController.browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
                isConnected = true
                
                DiscoveryViewController.clearSongDelegate?.getRidOfThatSong()
                connectedSessionIndexPath = indexPath
//                cell.activityIndicator.stopAnimating()
//                cell.connectingLabel.text = "Disconnect"
            }
        case false:
            cell.activityIndicator.startAnimating()
            MPCManager.sharedController.browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
            isConnected = true
            
            
            
            connectedSessionIndexPath = indexPath
//            cell.activityIndicator.stopAnimating()
//            cell.connectingLabel.text = "Disconnect"
        }
        
        self.previousCellIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? DiscoveryTableViewCell
        cell?.connectingLabel.text = ""
        cell?.activityIndicator.stopAnimating()
        cell?.activityIndicator.hidesWhenStopped = true
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Join a nearby broadcast"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
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
                
                let cell = self.tableView.cellForRow(at: self.selectedIndexPath!) as? DiscoveryTableViewCell ?? DiscoveryTableViewCell()
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidesWhenStopped = true
                cell.connectingLabel.text = "disconnect"
                self.parent?.tabBarController!.selectedIndex = 3
            }
        }
    }
    
    func disconnectWithPeer(peerID: MCPeerID) {
        if MPCManager.sharedController.isAdvertising == false {
            self.isConnected = false
            
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
