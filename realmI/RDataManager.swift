//
//  RDataManager.swift
//  testDiscogs
//
//  Created by FE Team TV on 8/2/16.
//  Copyright © 2016 courses. All rights reserved.
//

import ObjectMapper
import RealmSwift
import Alamofire
import AlamofireObjectMapper


class RDataManager {
    
    static let sharedManager = RDataManager()
   
    func getData(urlStr: String, callback:((Bool)->())?) {
        
        Alamofire.request(.GET, urlStr)
            .responseObject { (response: Response<RListUser, NSError>) in
                
                switch response.result {
                case .Success(let user):
                    do {
                        print(user)
                        print(uiRealm.configuration.fileURL)
                        try uiRealm.write {
                            uiRealm.add(user,update: true)                            
                        }
                    } catch let error as NSError {
                        print("Failure NSError")
                    }
                      case .Failure(let error):
                        print("Failure error")
                    }
                
                dispatch_async(dispatch_get_main_queue()) {
                    callback?(true)

           }
        }
}
        
    func delData(urlStr: String) {
        Alamofire.request(.DELETE, urlStr)
            .response { (request, response, data, error) in
                print(request)
                print(response)
        }
    }
    
    func updateData(urlStr: String, parameters: NSDictionary) {
        
        Alamofire.request(.POST, urlStr, parameters: parameters as? [String : AnyObject],  encoding: .JSON)
            .response { request, response, data, error in
                print(request)
                print(response)
                print(data)
        }
    }
    
    
    func updateDataPut(urlStr: String, parameters: NSDictionary) {
        
        Alamofire.request(.PUT, urlStr, parameters: parameters as? [String : AnyObject],  encoding: .JSON)
            .response { request, response, data, error in
                print(request)
                print(response)
                
        }
    }
}