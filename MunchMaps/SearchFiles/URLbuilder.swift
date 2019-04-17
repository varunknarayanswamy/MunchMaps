//
//  URLbuilder.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/12/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import Foundation

    let search = "https://developers.zomato.com/api/v2.1/search?q="
    let reviews = "https://developers.zomato.com/api/v2.1/reviews?res_id="


func create_search_url(lat:String, long: String, radius: String) -> String? {
    
    var url:String?
    let latstring = "&lat=" + lat
    let lonstring = "&lon=" + long
    let radiusString = "&radius=" + String(radius)
    url = search + latstring + lonstring + radiusString //+  "&sort=cost&order=asc"
    return url
}
