//
//  DataSourceProtocol.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 4/6/23.
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
    
    func generateLocationData( city : String, state: String, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void)
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([LocationData]?, NSError? ) -> Void)
    func generateWeatherData( currentLocationData : LocationData, completionHandler: @escaping (WeatherData?, NSError?) -> Void )
}
