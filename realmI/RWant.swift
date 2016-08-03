//
//  User.swift
//  testDiscogs
//
//  Created by FE Team TV on 8/2/16.
//  Copyright © 2016 courses. All rights reserved.
//


import RealmSwift
import ObjectMapper


class RWant: Object {
    
    dynamic var id = 0
    dynamic var rating = 0
    dynamic var resource_url = ""
    dynamic var labels_name = ""
    dynamic var labels_entity_type = ""
    dynamic var labels_catno = ""
    dynamic var labels_resource_url = ""
    dynamic var labels_id = 0
    dynamic var labels_entity_type_name = ""
    dynamic var formats_descriptions = ""
    dynamic var formats_name = ""
    dynamic var formats_qty = ""
    dynamic var thumb = ""
    dynamic var title = ""
    dynamic var artists_join = ""
    dynamic var artists_name = ""
    dynamic var artists_anv = ""
    dynamic var artists_tracks = ""
    dynamic var artists_role = ""
    dynamic var artists_resource_url = ""
    dynamic var artists_id = 0
    dynamic var year = 0
    dynamic var date_added = NSDate()
    
    let tasks = List<FirstO>()
    
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func IncrementaID() -> Int{
        let realm = try! Realm()
        let RetNext: NSArray = Array(realm.objects(RListWants).sorted("id"))
        let last = RetNext.lastObject
        if RetNext.count > 0 {
            let valor = last?.valueForKey("id") as? Int
            return valor! + 1
        } else {
            return 1
        }
    }
    func mapping(map: Map) {
       
        id <- map["id"]
        rating <- map["rating"]
        resource_url <- map["resource_url"]
        labels_name <- map["basic_information.labels.0.name"]
        labels_entity_type <- map["basic_information.labels.0.entity_type"]
        labels_catno <- map["basic_information.labels.0.labels_catno"]
        labels_resource_url <- map["basic_information.labels.0.resource_url"]
        labels_id <- map["basic_information.labels.0.id"]
        labels_entity_type_name <- map["basic_information.labels.0.entity_type_name"]
        formats_descriptions <- map["basic_information.formats.0.descriptions"]
        formats_name <- map["basic_information.formats.0.name"]
        formats_qty <- map["basic_information.formats.0.qty"]
        thumb <- map["basic_information.thumb"]
        title <- map["basic_information.title"]
        artists_join <- map["basic_information.artists.0.join"]
        artists_name <- map["basic_information.artists.0.name"]
        artists_anv <- map["basic_information.artists.0.anv"]
        artists_tracks <- map["basic_information.artists.0.tracks"]
        artists_role <- map["basic_information.artists.0.role"]
        artists_resource_url <- map["basic_information.artists.0.resource_url"]
        artists_id <- map["basic_information.artists.0.id"]
        year <- map["basic_information"]
        date_added  <- map["date_added"]
        
    }
    
}

