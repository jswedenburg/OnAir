//
//  DiscoveryTableViewCell.swift
//  OnAir
//
//  Created by Chandi Abey  on 11/2/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiscoveryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var peerLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    //adding space between the cells of a tableview
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 5
            frame.size.height -= 2 * 5
            super.frame = frame
        }
    }

    
    func updateSelectedBroadcastorWith(peer: MCPeerID!)
    {
        peerLabel?.text = peer.displayName
        connectingLabel.text = "Connecting...You will be on air shortly"
        activityIndicator.startAnimating()
    }
    
}
