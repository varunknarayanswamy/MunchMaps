//
//  URLbuilder.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/12/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import Foundation

    let search = "https://developers.zomato.com/api/v2.1/search?"
    let reviews = "https://developers.zomato.com/api/v2.1/reviews?res_id="


func create_search_url(lat:String, long: String, radius: String, start: Int, count: Int) -> String? {
    
    var url:String?
    let startString = "start=" + String(start)
    let countString = "&count=" + String(count)
    let latstring = "&lat=" + lat
    let lonstring = "&lon=" + long
    let radiusString = "&radius=" + String(radius)
    url = search + startString + countString + latstring + lonstring + radiusString +  "&sort=cost&order=desc"
    return url
}

func create_filter_url(lat:String, long: String, radius: String, cuisine: String, type: String, order: String) -> String? {
    print(cuisine)
    var url:String?
    let latstring = "&lat=" + lat
    let lonstring = "&lon=" + long
    let radiusString = "&radius=" + radius
    let cuisineString = "&cuisines=" + cuisine
    let typeString = "&sort=" + type
    let orderString = "&order=" + order
    print(typeString)
    print(orderString)
    url = search + latstring + lonstring + radiusString + cuisineString + typeString + orderString
    print(url)
    return url
}
