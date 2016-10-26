//
//  NetworkController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class NetworkController: NSObject {
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    
    static func performRequest(for url: URL,
                               httpMethodString: String,
                               urlParameters: [String: String]? = nil,
                               body: Data? = nil,
                               completion: ((Data?, Error?) -> Void)? = nil)
    {
        
        guard let httpMethod = HTTPMethod(rawValue: httpMethodString) else {
            NSLog("Invalid HTTP method \(httpMethodString)")
            completion?(nil, NSError(domain: "OnAirErrorDomain", code: 0, userInfo: nil))
            return
        }
        
        let requestURL = self.url(byAdding: urlParameters, to: url)
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            completion?(data, error)
        }
        
        dataTask.resume()
    }
    
    static func url(byAdding parameters: [String: String]?, to url: URL) -> URL
    {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = parameters?.flatMap({URLQueryItem(name: $0.0, value: $0.1)})
        
        if let url = components?.url {
            return url
        } else {
            fatalError("URL optional is nil")
        }
    }
}
