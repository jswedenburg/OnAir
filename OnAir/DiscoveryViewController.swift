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
   
    @IBOutlet weak var startStopAdvertisingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var broadcastLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.browser.startBrowsingForPeers()
        MPCManager.isBrowsing = true
        broadcastLabel.adjustsFontSizeToFitWidth = true
        let isBrowsingNotification = Notification.Name(rawValue: "isBrowsingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isBrowsingNotification, object: nil)
        let isAdvertisingNotification = NSNotification.Name(rawValue: "isAdvertisingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isAdvertisingNotification, object: nil)
    }
    
    @IBAction func broadcastButtonPressed(sender: UIButton) {
    
        if MPCManager.sharedController.isAdvertising {
            startStopAdvertisingButton.setTitle("Start Broadcasting", for: .normal)
            MPCManager.sharedController.advertiser.stopAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = false
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "broadcastCell", for: indexPath)
        
        let peer = MPCManager.sharedController.foundPeers[indexPath.row]
        cell.textLabel?.text = peer.displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = MPCManager.sharedController.foundPeers[indexPath.row] as MCPeerID
        guard let session = MPCManager.sharedController.session else { return }
        MPCManager.sharedController.browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
        broadcastLabel.text = "YOU ARE VIBING WITH \(peer.displayName)"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose or Start a Broadcast"
    }
}

extension DiscoveryViewController: MPCManagerDelegate{
    
    func foundPeer(){
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        if MPCManager.sharedController.isAdvertising == false {
            
            self.parent?.parent?.tabBarController!.selectedIndex = 3
            
        }
    }
}
