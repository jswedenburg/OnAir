//
//  ReceiverMusicPlayerViewController.swift
//  OnAir
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class ListenerMusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(notification:)), name: NSNotification.Name(rawValue: "receivedData"), object: nil)
    }
    
    func dataReceived(notification: Notification){
        guard let data = notification.object as? Data else { print("Object failed to convert to Data"); return }
        guard let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String] else { print("Data failed to convert to dictionary of [String: String]"); return }
        guard let value = dictionary.first?.value else { return }
        
        switch value{
        case "play":
            print("play")
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
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        
        MusicPlayerController.sharedController.listenerPause()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
