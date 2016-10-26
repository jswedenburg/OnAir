//
//  ImageController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation
import UIKit

class ImageController {
    
    static func imageForURL(imageEndpoint: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        //let endpoint = baseURL?.URLByAppendingPathComponent("\(imageEndpoint)").URLByAppendingPathExtension("json")
        
        guard let url = NSURL(string: imageEndpoint) else { fatalError("Image URL optional is nil") }
        
        NetworkController.performRequest(for: url as URL, httpMethodString: "GET") { (data, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
    }
}
