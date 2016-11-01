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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.browser.startBrowsingForPeers()
        MPCManager.isBrowsing = true
        let isBrowsingNotification = Notification.Name(rawValue: "isBrowsingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isBrowsingNotification, object: nil)
        let isAdvertisingNotification = NSNotification.Name(rawValue: "isAdvertisingChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(advertisingBrowsingIdentify), name: isAdvertisingNotification, object: nil)
    }
    
    @IBAction func broadcastButtonPressed(sender: UIButton) {
    
        if MPCManager.sharedController.isAdvertising {
            startStopAdvertisingButton.setTitle("Start Advertising", for: .normal)
            MPCManager.sharedController.advertiser.stopAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = false
            self.tableView.isUserInteractionEnabled = true
        } else {
            startStopAdvertisingButton.setTitle("Stop Advertising", for: .normal)
            MPCManager.sharedController.advertiser.startAdvertisingPeer()
            MPCManager.sharedController.isAdvertising = true
            self.tableView.isUserInteractionEnabled = false
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
            self.tabBarController?.selectedIndex = 2
        }
    }
}
