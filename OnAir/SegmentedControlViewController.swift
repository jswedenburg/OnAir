//
//  SegmentedControlViewController.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SegmentedControlViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var songQueueView: UIView!
    
    
    
    
    
    @IBAction func showComponent(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchView.alpha = 1
                self.songQueueView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchView.alpha = 0
                self.songQueueView.alpha = 1
            })
        }
    }


    
    

}
