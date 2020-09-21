//
//  VenueManager.swift
//  PennLabsDining
//
//  Created by Daniel Duan on 9/21/20.
//

import Foundation

struct VenueManager {
    let venueURL = "https://api.pennlabs.org/dining/venues"
    
    func performRequest() {
        // Create URL, optionally unwrap it
        if let url = URL(string: venueURL) {
            // Create URL Session
            let session = URLSession(configuration: .default)
            // Give Session task
            let task = session.dataTask(with: url) { (data, response, error) in
                // error handling
                if error != nil {
                    print(error!)
                    return
                }
                
                // if there's no error, proceed to optionally unwrap the data and parse the JSON object
                if let safeData = data {
                    self.parseJSON(venueData: safeData)
                }
            }
            // Start task
            task.resume()
        }
        
    }
    
    func parseJSON(venueData: Data) {
        // create decoder
        let decoder = JSONDecoder()
        // pass in VenueData type
        do {
            let decodedData = try decoder.decode(VenueData.self, from: venueData)
            let arr = decodedData.document.venue
        } catch {
            print(error)
        }
    }
    
}
