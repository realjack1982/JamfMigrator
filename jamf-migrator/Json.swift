//
//  Json.swift
//  jamf-migrator
//
//  Created by Leslie Helou on 12/1/19.
//  Copyright © 2019 jamf. All rights reserved.
//

import Cocoa

class Json: NSObject, URLSessionDelegate {
    func getRecord(whichServer: String, theServer: String, base64Creds: String, theEndpoint: String, completion: @escaping (_ result: [String:AnyObject]) -> Void) {
        
        if theEndpoint == "skip" {
            completion([:])
            return
        }
        
        let userDefaults   = UserDefaults.standard
        let objectEndpoint = theEndpoint.replacingOccurrences(of: "//", with: "/")
        WriteToLog().message(stringOfText: "[Json.getRecord] get endpoint: \(objectEndpoint) from server: \(theServer)\n")
    
        URLCache.shared.removeAllCachedResponses()
        var existingDestUrl = ""
        
        existingDestUrl = "\(theServer)/JSSResource/\(objectEndpoint)"
        existingDestUrl = existingDestUrl.urlFix
        
        if LogLevel.debug { WriteToLog().message(stringOfText: "[Json.getRecord] Looking up: \(existingDestUrl)\n") }
//      print("existing endpoints URL: \(existingDestUrl)")
        let destEncodedURL = URL(string: existingDestUrl)
        let jsonRequest    = NSMutableURLRequest(url: destEncodedURL! as URL)

        q.getRecord.maxConcurrentOperationCount = userDefaults.integer(forKey: "concurrentThreads")
        
        let semaphore = DispatchSemaphore(value: 0)
        q.getRecord.addOperation {
//        getRecordQ.async {
            
            jsonRequest.httpMethod = "GET"
            let destConf = URLSessionConfiguration.ephemeral
//           = ["Authorization" : "Basic \(base64Creds)", "Content-Type" : "application/json", "Accept" : "application/json"]
            destConf.httpAdditionalHeaders = ["Authorization" : "\(String(describing: JamfProServer.authType[whichServer]!)) \(String(describing: JamfProServer.authCreds[whichServer]!))", "Content-Type" : "application/json", "Accept" : "application/json", "User-Agent" : appInfo.userAgentHeader]
            let destSession = Foundation.URLSession(configuration: destConf, delegate: self, delegateQueue: OperationQueue.main)
            let task = destSession.dataTask(with: jsonRequest as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                destSession.finishTasksAndInvalidate()
                if let httpResponse = response as? HTTPURLResponse {
//                    print("[Json.getRecord] httpResponse: \(String(describing: httpResponse))")
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            if let endpointJSON = json as? [String:AnyObject] {
                                WriteToLog().message(stringOfText: "[Json.getRecord] retrieved \(theEndpoint)\n")
                                if LogLevel.debug { WriteToLog().message(stringOfText: "[Json.getRecord] \(endpointJSON)\n") }
                                completion(endpointJSON)
                            } else {
                                WriteToLog().message(stringOfText: "[Json.getRecord] error parsing JSON for \(existingDestUrl)\n")
                                completion([:])
                            }
                        }
                    } else {
                        WriteToLog().message(stringOfText: "[Json.getRecord] error getting \(theEndpoint), HTTP Status Code: \(httpResponse.statusCode)\n")
                        completion([:])
                    }
                } else {
                    WriteToLog().message(stringOfText: "[Json.getRecord] error parsing JSON for \(existingDestUrl)\n")
                    completion([:])
                }   // if let httpResponse - end
                semaphore.signal()
                if error != nil {
                }
            })  // let task = destSession - end
            //print("GET")
            task.resume()
            semaphore.wait()
        }   // getRecordQ - end
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}

