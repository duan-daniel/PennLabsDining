//
//  Venue.swift
//  PennLabsDining
//
//  Created by Daniel Duan on 9/21/20.
//

import Foundation

struct Venue {
    var venueType, name, imageURL, facilityURL, hours, status: String
    init(venueType: String, name: String, imageURL: String, facilityURL: String, hours: String, status: String) {
        self.venueType = venueType
        self.name = name
        self.imageURL = imageURL
        self.facilityURL = facilityURL
        self.hours = hours
        self.status = status
    }
}

