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
import SwiftyJSON


class RDataManager {
    
    static let sharedManager = RDataManager()
    
   /* func getName(text: String, callback: ([SearchName] -> ())?) {
     
       let urlStr = "https://api.discogs.com/database/search?q=\(text)&token=JTmFFQvqhkXoEMqUYvwgFaUafYYzrpXfSKJQlocc"
        Alamofire.request(.GET, urlStr)
               .responseJSON { response in
                var iData = [SearchName]()
               let json = JSON(response.result.value!)
               let resultJ = json["results"].arrayValue
                
               for el in resultJ {
                    let iElem = SearchName()
                if let iid = el["id"].int {
                     iElem.id = iid }
                if let iname = el["title"].string {
                     iElem.name = iname }
                 iData.append(iElem)
                 
                }
            
        dispatch_async(dispatch_get_main_queue()) {
            callback?(iData)
        }
        }
    }*/
   
    func getData(i: Int, callback:((Bool)->())?) {
        
      Alamofire.request(.GET, "https://api.discogs.com/users/innablack/wants?per_page=50&page=\(i)").responseArray(keyPath: "wants") { (response: Response<[RListWants], NSError>) in
                switch response.result {
                case .Success(let wants):
                    do {
                        print(uiRealm.configuration.fileURL)
                    for want in wants {
                        try uiRealm.write {
                            uiRealm.add(want,update: true)    }
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
    
    func delData(urlStr: String, idRow: Int) {
        Alamofire.request(.DELETE, urlStr)
            .response { (request, response, data, error) in
              let listToBeDeleted = uiRealm.objects(RListWants).filter("status = %@ AND id= %@", status.deleted.rawValue, idRow)
              uiRealm.beginWrite()
              uiRealm.delete(listToBeDeleted)
              try! uiRealm.commitWrite()
              print("deleted\(idRow)")
        }       
    }
    
    func updateData(urlStr: String, parameters: NSDictionary, idRow: Int) {
        
        Alamofire.request(.POST, urlStr, parameters: parameters as? [String : AnyObject],  encoding: .JSON)
            .response { request, response, data, error in
             let updatedList = uiRealm.objects(RListWants).filter("status = %@ AND id= %@", status.updated.rawValue, idRow)
             try! uiRealm.write({ () -> Void in
             updatedList.first?.status = status.non.rawValue
             print("updateed\(idRow)")
             })
        }
    }
    
    func updateDataPut(urlStr: String, parameters: NSDictionary, idRow: Int) {
        
        Alamofire.request(.PUT, urlStr, parameters: parameters as? [String : AnyObject],  encoding: .JSON)
            .response { request, response, data, error in
            let updatedList = uiRealm.objects(RListWants).filter("status = %@ AND id= %@", status.added.rawValue, idRow)
            try! uiRealm.write({ () -> Void in
            updatedList.first?.status = status.non.rawValue
            print("added\(idRow)")
            })
        }
    }
    
    func synRealtoDiscogs() {
        
        let lists = uiRealm.objects(RListWants)     
        var index = lists.count - 1
        while index >= 0 {
            let el = lists[index]
            switch  el.status {
            case status.added.rawValue:
              let param = [ "username" : "innablack",
                 "release_id" : el.IncrementaID(),
                  "rating" : el.rating]
              RDataManager.sharedManager.updateDataPut("https://api.discogs.com/users/innablack/wants/\(el.id)?token=JTmFFQvqhkXoEMqUYvwgFaUafYYzrpXfSKJQlocc", parameters: param, idRow: index)
            case status.updated.rawValue:
               let param = [
                 "username": "innablack",
                 "rating" : el.rating,
                 "release_id": el.id]
                 RDataManager.sharedManager.updateData("https://api.discogs.com/users/innablack/wants/\(el.id)?token=JTmFFQvqhkXoEMqUYvwgFaUafYYzrpXfSKJQlocc", parameters: param, idRow:index)
            case status.deleted.rawValue:
                 RDataManager.sharedManager.delData("https://api.discogs.com/users/innablack/wants/\(el.id)?token=JTmFFQvqhkXoEMqUYvwgFaUafYYzrpXfSKJQlocc", idRow: el.id)
            default:
                print("none\(el.id)")
            }
            index = index - 1
        }
   
    }
    
}