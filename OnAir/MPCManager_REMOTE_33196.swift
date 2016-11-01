//
//  MPCManager.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

protocol MPCManagerDelegate {

    func foundPeer()
    
    func connectedWithPeer(peerID: MCPeerID)

}

class MPCManager: NSObject , MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    static let sharedController = MPCManager()
    
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers: [MCPeerID] = []
    
    var connectedPeers: [MCPeerID] = []
    
    var isAdvertising: Bool = false {
        didSet {
            let name = Notification.Name(rawValue: "isAdvertisingChanged")
            NotificationCenter.default.post(name: name, object: isAdvertising)
        }
    }

    let serviceType = "LCOC-Chat"

    override init(){
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: self.serviceType)
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: self.serviceType)
        advertiser.delegate = self
    }
    
    
    //MARK: Broswer Delegate 
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
    }
    
    // Advertiser Delegate
    
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        invitationHandler(true, self.session)

        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    // Session Delegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            delegate?.connectedWithPeer(peerID: peerID)
            connectedPeers.append(peerID)
            print("connected")
        case MCSessionState.connecting:
            print("Connecting")
        default:
            print("Did not connect")
        }
    }
    
     func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let name: NSNotification.Name = NSNotification.Name.init(rawValue: "receivedData")
        NotificationCenter.default.post(name: name, object: data)
    }
    
   
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    // MARK: Custom Helper Functions
    
    func sendData(dictionary: Dictionary<String, String>) {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try session.send(dataToSend, toPeers: self.connectedPeers, with: .unreliable)
        } catch  {
            print("Sending Failed")
        }
    }
}
