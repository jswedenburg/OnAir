//
//  SubscriptionController.swift
//  OnAir
//
//  Created by Jake Swedenburg on 11/3/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

import Foundation
import StoreKit

protocol SubscriptionDelegate {
    var aMusic: Bool { get set }
    var iCloud: Bool { get set }
}

class SubscriptionController {
    
    
    
    static let cloudSC = SKCloudServiceController()
    
    static func requestStoreKitPermission(completion: @escaping (_ success: Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { (authStatus) in
            if authStatus == SKCloudServiceAuthorizationStatus.authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    static func requestCapabilities(completion: @escaping (_ AMusicAccount: Bool, _ withICloud: Bool) -> Void) {
        cloudSC.requestCapabilities { (capabilites, error) in
            if let error = error {
                print(error.localizedDescription)
                //handle error
            }
            
            switch capabilites {
            case SKCloudServiceCapability.musicCatalogPlayback:
                completion(true, false)
                print("Has amusic but no icloud")
            case SKCloudServiceCapability.addToCloudMusicLibrary:
                completion(true, true)
                print("Has amusic and icloud")
            default:
                completion(false, false)
                print("no amusic :-(")
            
            }
            
            
        }
    }
    
}
