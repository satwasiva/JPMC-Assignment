//
//  DataSourceProtocol.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation

class DataSourceFromNetwork : DataSourceProtocol {
    var source : ContentSourceType = .bundleJSON
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
            let networkService = AppScopeDependencyContainer.shared.networkingService
            if  locationsData[searchTerm] != nil {
                completionHandler(locationsData[searchTerm], nil)
                return
            }
            
        execQueue.async {
            networkService.getLocationSearchResults(searchTerm: searchTerm) {
                locationList, error in
                var localList = locationList
                if localList != nil && localList!.count > 0 {
                    if state != "" && localList!.count > 1 {
                        while localList!.count > 1 { localList!.removeLast() }
                    }
                }
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    self.locationsData[searchTerm] = localList
                    completionHandler(localList, nil)
                }
            }
        }
    }
    
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        let networkService = AppScopeDependencyContainer.shared.networkingService
        
        execQueue.async {
            networkService.getLocationSearchResults(lat : lat, lon : lon) {
                locationList, error in
                var localList = locationList
                if localList != nil && localList!.count > 0 {
                    if localList!.count > 1 {
                        while localList!.count > 1 { localList!.removeLast() }
                    }
                }
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    let searchTerm = localList![0].name + "," + localList![0].state + "," + localList![0].country
                    self.locationsData[searchTerm] = localList
                    completionHandler(localList, nil)
                }
            }
        }
    }
    
    func generateWeatherData( currentLocationData : LocationData, completionHandler: @escaping (WeatherData?, NSError?) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
            let networkService = AppScopeDependencyContainer.shared.networkingService
        execQueue.async {
            networkService.getWeatherSearchResults(latitude: currentLocationData.lat, longitude: currentLocationData.lon) { weather, error in
                self.weatherData = weather
                completionHandler(weather, nil)
            }
        }
    }
}
