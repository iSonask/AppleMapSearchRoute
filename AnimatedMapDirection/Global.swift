//
//  Global.swift
//  AnimatedMapDirection
//
//  Created by SHANI SHAH on 06/12/18.
//  Copyright © 2018 SHANI SHAH. All rights reserved.
//

import UIKit
import CoreLocation

class Global: NSObject {

    static var shared = Global()
    
    var locations = CLLocationCoordinate2D()
    
}

class Constant: NSObject {
    
    // #MARK:- Near by
    static var MAPNEARBY = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    static var SEARCHAPI = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    
    static var GETLATLONGAPI = "https://maps.googleapis.com/maps/api/place/details/json?"
    // #MARK:- Google api key
    static var GOOGLEAPIKEY = "AIzaSyC_eeeqt_D-hS6L9_hb4jXg43knv0HnbLQ"
    
    static var MAXWAYPOINTS =  5
    
    static var pinLatitude = ""
    static var pinLongitude = ""
    
}
