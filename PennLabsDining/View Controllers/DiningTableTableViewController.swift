//
//  DiningTableTableViewController.swift
//  PennLabsDining
//
//  Created by Daniel Duan on 9/21/20.
//

import UIKit

class DiningTableTableViewController: UITableViewController {
    
    var residentialArray = [Venue]()
    var retailArray = [Venue]()
    
    let sections = ["Dining Halls", "Retail Dining"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the current date
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateString = formatter.string(from: currentDate)
        self.navigationItem.title = dateString

        // adjust tableView styles
        tableView.rowHeight = 125
        tableView.separatorStyle = .none
        
        loadVenues()
    }
    
    // MARK: - API + Response
    
    func loadVenues() {
        
        // Create URL, optionally unwrap it
        if let url = URL(string: "https://api.pennlabs.org/dining/venues") {
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
            populateArrays(venueArray: decodedData.document.venue)
        } catch {
            print(error)
        }
    }
    
    /*
     populateArrays essentially populates residentialArray and retailArray with all the venues parsed from JSON Data.
     These two arrays are used to populate the table view.
     */
    func populateArrays(venueArray: [VenueObj]) {
        // get current date
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let todayDate = formatter.string(from: currentDate)
        
        // Iterate through every venue in the API
        for venue in venueArray {
            
            // First the intial values of the newVenue to Closed. The code will update it if necessary.
            var newVenue = Venue(venueType: venue.venueType, name: venue.name, imageURL: venue.imageURL, facilityURL: venue.facilityURL, hours: "Closed Today", status: "CLOSED")
            
            // Check to see if the venue does have dining hours
            if venue.dateHours != nil {
                
                // Iterate through "dateHours" key and find the dining hours for today's date
                for dateObj in venue.dateHours! {
                    
                    if (dateObj.date == todayDate) {
                        
                        // openTimes stores all the opening hours for today
                        // closedTimes stores all the closing hours for today
                        var openTimes = [String]()
                        var closedTimes = [String]()
                        
                        // Iterate through "meal" key
                        for mealObj in dateObj.meal {
                            openTimes.append(mealObj.open)
                            closedTimes.append(mealObj.close)
                        }
                        
                        // there are dining hours, so reset dining hours string
                        newVenue.hours = ""
                    
                        // iterate through openTimes to pair opening times with closing times for each venue
                        for index in 0...openTimes.count - 1 {
                            // Prettify the hours of operations
                            let openT = prettifyHours(str: openTimes[index])
                            let closedT = prettifyHours(str: closedTimes[index])
                            
                            // update newVenue's hours based on the JSON Data
                            newVenue.hours += (openT + "-" + closedT + " | ")
                            
                            // Check to see if the current time falls within openT and closedT
                            if (isOpen(startStr: openT, closeStr: closedT)) {
                                newVenue.status = "OPEN"
                            }
                            
                        }
                        // UI Preferences - removes the last "|" of the hours string
                        newVenue.hours.removeLast()
                        newVenue.hours.removeLast()
                    }

                }

            }
                        
            // Depending on the type of venue (residential vs retail), append it to the appropriate array
            if (newVenue.venueType == "residential") {
                residentialArray.append(newVenue)
            }
            else {
                retailArray.append(newVenue)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    // MARK: - Helper Functions
    
    /*
     UI Preferences - changes 07:30:00 -> 07:30
     */
    func prettifyHours(str: String) -> String {
        let newStr = str.prefix(5)
        return String(newStr)
    }
    /*
     Checks to see if the current time is within opening and closing hours
     Code Taken from: https://stackoverflow.com/questions/29652771/how-to-check-if-time-is-within-a-specific-range-in-swift
     */
    func isOpen(startStr: String, closeStr: String) -> Bool {
        let todaysDate  = Date()
        
        // convert strings to `Date` objects
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.date(from: startStr)
        let endTime = formatter.date(from: closeStr)
        
        // extract hour and minute from those `Date` objects

        let calendar = Calendar.current

        var startComponents = calendar.dateComponents([.hour, .minute], from: startTime!)
        var endComponents = calendar.dateComponents([.hour, .minute], from: endTime!)

        // extract day, month, and year from `todaysDate`

        let nowComponents = calendar.dateComponents([.month, .day, .year], from: todaysDate)

        // adjust the components to use the same date

        startComponents.year  = nowComponents.year
        startComponents.month = nowComponents.month
        startComponents.day   = nowComponents.day

        endComponents.year  = nowComponents.year
        endComponents.month = nowComponents.month
        endComponents.day   = nowComponents.day

        // combine hour/min from date strings with day/month/year of `todaysDate`

        guard
            let startDate = calendar.date(from: startComponents),
            let endDate = calendar.date(from: endComponents)
        else {
            print("unable to create dates")
            return false
        }

        // now we can see if today's date is inbetween these two resulting `NSDate` objects
        let isInRange = todaysDate > startDate && todaysDate < endDate
        return isInRange
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return residentialArray.count
        }
        else {
            return retailArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        cell.headerLabel.text = sections[section]
        return cell
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "venueCell") as! VenueTableViewCell
        
        if (indexPath.section == 0) {
            let venue = residentialArray[indexPath.row]
            cell.venueNameLabel.text = venue.name
            cell.venueStatusLabel.text = venue.status
            cell.venueHoursLabel.text = venue.hours
            // see Extensions.swift for asynchronously updating the images
            cell.imageOfVenue.load(urlString: venue.imageURL)
        }
        else {
            let venue = retailArray[indexPath.row]
            cell.venueNameLabel.text = venue.name
            cell.venueStatusLabel.text = venue.status
            cell.venueHoursLabel.text = venue.hours
            cell.imageOfVenue.load(urlString: venue.imageURL)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
