//
//  DataUtilities.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 4/6/23.
//

import Foundation

class DataUtilities {
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    static public func generateLocationDataFromBundleJSONFile( searchTerm : String, sourceFile : String ) -> ([LocationData]?, NSError?) {
        
        var locationsData : [LocationData]? = nil
        var error : NSError? = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                locationsData =  try decoder.decode([LocationData].self, from: data)

            } catch let decodeError as NSError {
                error = decodeError
            }
        }
        
        return (locationsData, error)
    }
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    static public func generateWeatherDataFromBundleJSONFile( sourceFile:String ) -> (WeatherData?, NSError?) {
        var weatherData : WeatherData? = nil
        var error : NSError? = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                weatherData = try decoder.decode(WeatherData.self, from: data)
                
            } catch let decodeError as NSError {
                error = decodeError
            }
        }
        
        return (weatherData, error)
    }
}
