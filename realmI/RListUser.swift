//
//  User.swift
//  testDiscogs
//
//  Created by FE Team TV on 8/2/16.
//  Copyright © 2016 courses. All rights reserved.
//


import RealmSwift
import ObjectMapper


class RListUser: Object, Mappable {
    
    dynamic var id = 0
    dynamic var username = ""
    dynamic var profile = ""
    dynamic var num_collection = 0
    dynamic var collection_fields_url = ""
    dynamic var releases_contributed = 0
    dynamic var rating_avg = 0.00
    dynamic var registered = NSDate()
    dynamic var wantlist_url = ""
    dynamic var seller_num_ratings = 0
    dynamic var rank  = 0.0
    dynamic var releases_rated = 0
    dynamic var buyer_rating = 0.0
    dynamic var num_pending = 0
    dynamic var seller_rating_stars = 0.0
    dynamic var resource_url = ""
    dynamic var num_lists = 0
    dynamic var name = ""
    dynamic var num_for_sale = 0
    dynamic var buyer_rating_stars = 0.0
    dynamic var home_page = ""
    dynamic var num_wantlist = 0
    dynamic var inventory_url = ""
    dynamic var uri = ""
    dynamic var buyer_num_ratings = 0
    dynamic var avatar_ur = ""
    dynamic var location = ""
    dynamic var collection_folders_url = ""
    dynamic var seller_rating = 0.0
    let tasks = List<FirstO>()
    
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {        
        id <- map["id"]
        username <- map["username"]
        profile <- map["profile"]
        num_collection <- map["num_collection"]
        collection_fields_url <- map["collection_fields_url"]
        releases_contributed <- map["releases_contributed"]
        rating_avg <- map["rating_avg"]
        registered <- (map["registered"], DateTransform())
        wantlist_url <- map["wantlist_url"]
        seller_num_ratings <- map["seller_num_ratings"]
        rank  <- map["rank"]
        releases_rated <- map["releases_rated"]
        buyer_rating <- map["buyer_rating"]
        num_pending <- map["num_pending"]
        seller_rating_stars <- map["seller_rating_stars"]
        resource_url <- map["resource_url"]
        num_lists <- map["num_lists"]
        name <- map["name"]
        num_for_sale <- map["num_for_sale"]
        buyer_rating_stars <- map["buyer_rating_stars"]
        home_page <- map["home_page"]
        num_wantlist <- map["num_wantlist"]
        inventory_url <- map["inventory_url"]
        uri <- map["uri"]
        buyer_num_ratings <- map["buyer_num_ratings"]
        avatar_ur <- map["avatar_ur"]
        location <- map["location"]
        collection_folders_url <- map["collection_folders_url"]
        seller_rating <- map["seller_rating"]
    }
}

