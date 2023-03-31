//
//  DataSourceProtocol.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation

// Source type of the weather data. Appropriate source can be selected based on what the object's source is set to.
enum ContentSourceType {
    case bundleJSON // To designate data source as bundle provided JSON, usually for testing
    case fileStorage // To designate data source as on device JSON, usually for testing
    case networkLocation // To designate data source as external network location, for production usage
}

// A protocol for data source. The source can be getting data from network or local files (testing) etc.
protocol DataSourceProtocol {
    var weatherData : WeatherData? { get }
    var locationsData : [String : [LocationData]] { get }
    init( sourceType:ContentSourceType )
    
    func generateLocationData( city : String, state: String, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void)
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void)
    func generateWeatherData( currentLocationData : LocationData, completionHandler: @escaping (WeatherData?, NSError?) -> Void )
}


class DataSource : DataSourceProtocol {
    var source : ContentSourceType
    var weatherData: WeatherData?
    var locationsData : [String : [LocationData]] = [String : [LocationData]]()
    
    let defaultCountry = "US" // Could be populated using a configuration class
    
    required init( sourceType:ContentSourceType ) {
        source = sourceType
    }
    
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
        switch source {
        case .bundleJSON:
            execQueue.async {
                if self.generateLocationDataFromBundleJSONFile(searchTerm: searchTerm, sourceFile: "locationsMock") {
                    completionHandler(self.locationsData[searchTerm], nil)
                } else {
                    let error = NSError(domain: "ErrorParsingLocationJSONDomain", code: 102, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON file provided"])
                    completionHandler(nil, error)
                }
                return
            }
        case .fileStorage:
            print("Not supported yet!!")
            return
        case .networkLocation:
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
            return
        }
        return
    }
    
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        switch source {
        case .bundleJSON:
            print("Not supported yet!!")
            return
        case .fileStorage:
            print("Not supported yet!!")
            return
        case .networkLocation:
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
            return
        }
    }
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    private func generateLocationDataFromBundleJSONFile( searchTerm : String, sourceFile : String ) -> Bool {
        locationsData[searchTerm] = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                locationsData[searchTerm] = try decoder.decode([LocationData].self, from: data)
                return true
            } catch _ as NSError {
                
                return false
            }
        }
        
        return false
    }
    
    func generateWeatherData( currentLocationData : LocationData, completionHandler: @escaping (WeatherData?, NSError?) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
        switch source {
            
        case .bundleJSON:
            execQueue.async {
                if self.generateWeatherDataFromBundleJSONFile(sourceFile: "weatherFremontMock") {
                    completionHandler(self.weatherData, nil)
                } else {
                    let error = NSError(domain: "ErrorParsingWeatherJSONDomain", code: 103, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON file provided for weather info"])
                    completionHandler(nil, error)
                }
                return
            }
        case .fileStorage:
            print("Not supported yet!!")
            return
        case .networkLocation:
            let networkService = AppScopeDependencyContainer.shared.networkingService
            execQueue.async {
                networkService.getWeatherSearchResults(latitude: currentLocationData.lat, longitude: currentLocationData.lon) { weather, error in
                    self.weatherData = weather
                    completionHandler(weather, nil)
                }
            }
        }
    }
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    private func generateWeatherDataFromBundleJSONFile( sourceFile:String ) -> Bool {
        weatherData = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                weatherData = try decoder.decode(WeatherData.self, from: data)
                return true
            } catch let decodeError as NSError {
                print(decodeError)
                return false
            }
        }
        
        return false
    }
}
