//
//  DataSourceWithLocalJSON.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 4/6/23.
//

import Foundation

class DataSourceWithLocalJSON : DataSourceProtocol {
    
    var source : ContentSourceType = .networkLocation
    var weatherData: WeatherData?
    var locationsData : [String : [LocationData]] = [String : [LocationData]]()
    
    let defaultCountry = "US" // Could be populated using a configuration class
    
    func generateLocationData( city : String, state : String, completionHandler : @escaping ([LocationData]?, NSError?) -> Void ) {
        
        guard city != "" else {
            let error = NSError(domain: "MissingInfoErrorDomain", code: 101, userInfo: [NSLocalizedDescriptionKey: "Missing either city or state info in the search string"])
            completionHandler(nil, error)
            return
        }
        
        var searchTerm = city
        if state == "" {
            searchTerm += "," + defaultCountry
        } else {
            searchTerm += "," + state + "," + defaultCountry
        }
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
        execQueue.async {
            let (locationsData, error) = DataUtilities.generateLocationDataFromBundleJSONFile(searchTerm: searchTerm, sourceFile: "locationsMock")
            completionHandler(locationsData, error)
        }
    }
    
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void) {
       
        print("Not supported yet!!")
        return
    }
    
    func generateWeatherData( currentLocationData : LocationData, completionHandler: @escaping (WeatherData?, NSError?) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
        execQueue.async {
            let (weatherData, decodeError) = DataUtilities.generateWeatherDataFromBundleJSONFile(sourceFile: "weatherFremontMock")
            completionHandler(weatherData, decodeError)
        }
    }
}
