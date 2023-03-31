//
//  QueryService.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation
import UIKit.UIImage

class NetworkQueryService {
    let APIKey = "8192785fdcac87824d4b0316499f8f2c"
    let geocodeAPIStr = "https://api.openweathermap.org/geo/1.0/direct"
    let reverseGeoAPIStr = "https://api.openweathermap.org/geo/1.0/reverse"
    let weatherAPIStr = "https://api.openweathermap.org/data/2.5/weather"
    var iconImageURLStr = "https://openweathermap.org/img/wn"
    
    let resultsLimit = 3
    
    var locations : [LocationData] = []
    var weather : WeatherData?
    
    var locServiceError : NSError? = nil
    var weatherServiceError : NSError? = nil
    
    lazy var defaultSession : URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
    
    var locationDataTask : URLSessionDataTask?
    var weatherDataTask : URLSessionDataTask?
    
    let decoder = JSONDecoder()
    
    func getLocationSearchResults( searchTerm:String, completionHandler : @escaping ([LocationData]?, NSError?) -> () ) {
        locationDataTask?.cancel()
        
        guard searchTerm != "" else { return }
        
        guard var components = URLComponents(string: geocodeAPIStr) else { return }
        
        components.query = "q=\(searchTerm)&limit=\(resultsLimit)&appid=\(APIKey)"
        
        guard let urlRequest = components.url else { return }
        locationDataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            defer { self.locationDataTask = nil }
            
            if let error = error {
                self.locServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                self.parseLocationDataResponse(data)
            }
            completionHandler(self.locations, self.locServiceError)
        }
        locationDataTask?.resume()
    }
    
    fileprivate func parseLocationDataResponse( _ data : Data ) {
        locations.removeAll()
        locServiceError = nil
        
        do {
            locations = try decoder.decode([LocationData].self, from: data)
        } catch let decodeError as NSError {
            locServiceError = decodeError
            return
        }
    }
    
    func getLocationSearchResults( lat:Double, lon:Double, completionHandler : @escaping ([LocationData]?, NSError?) -> () ) {
        locationDataTask?.cancel()
        
        guard var components = URLComponents(string: reverseGeoAPIStr) else { return }
        
        components.query = "lat=\(lat)&lon=\(lon)&limit=1&appid=\(APIKey)"
        
        guard let urlRequest = components.url else { return }
        locationDataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            defer { self.locationDataTask = nil }
            
            if let error = error {
                self.locServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                self.parseLocationDataResponse(data)
            }
            completionHandler(self.locations, self.locServiceError)
        }
        locationDataTask?.resume()
    }
    
    func getWeatherSearchResults( latitude:Double, longitude:Double, completionHandler : @escaping (WeatherData?, NSError?) -> () ) {
        weatherDataTask?.cancel()
        weatherServiceError = nil
        
        guard var components = URLComponents(string: weatherAPIStr) else { return }
        
        components.query = "lat=\(latitude)&lon=\(longitude)&appid=\(APIKey)"
        guard let urlRequest = components.url else { return }
        
        weatherDataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            defer { self.weatherDataTask = nil }
            
            if let error = error {
                self.weatherServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self.parseWeatherDataResponse(data)
            }
            completionHandler(self.weather, self.weatherServiceError)
        }
        weatherDataTask?.resume()
    }
    
    fileprivate func parseWeatherDataResponse( _ data : Data ) {
        weather = nil
        
        do {
            weather = try decoder.decode(WeatherData.self, from: data)
        } catch let decodeError as NSError {
            weatherServiceError = decodeError
        }
    }
    
    func downloadImage( resource : String, completionHandler : @escaping (UIImage?, NSError?) -> Void ) {
        guard resource != "" else { return }
        
        let url = URL(string: iconImageURLStr + "/" + resource + "@2x.png")!
        let imageDataTask = defaultSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error as? NSError {
                completionHandler(nil, error)
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let image = UIImage(data: data)
                completionHandler(image, nil)
            }
        }
        imageDataTask.resume()
    }
}
