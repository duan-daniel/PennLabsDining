//
//  VenueData.swift
//  PennLabsDining
//
//  Created by Daniel Duan on 9/21/20.
//

import Foundation

// have VenueData conform to Decodable protocol to parse JSON Data
struct VenueData: Decodable {
    let document: Document
}

struct Document: Decodable {
    let venue: [VenueObj]
}

struct VenueObj: Decodable {
    let imageURL: String
    let name: String
    let venueType: String
    let facilityURL: String
    let dateHours: [DateObj]?
}

struct DateObj: Decodable {
    let date: String
    let meal: [MealObj]
}

struct MealObj: Decodable {
    let close: String
    let open: String
    let type: String
}
// document.venue[0].dateHours
// document.venue[0].dateHours[0].meal[0].close

