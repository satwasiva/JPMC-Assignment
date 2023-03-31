//
//  SearchCurrentWeatherInfoViewModel.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 3/29/23.
//

import Foundation
import UIKit.UIImage
import MapKit

class SearchCurrentWeatherInfoViewModel {
    private let weatherQueryController : WeatherQueryController
    private var locationData : LocationData?
    private var weatherData : WeatherData?
    
    // Associated properties that set receivers in any view controller that uses this view model
    let locationName = PropertyPackage(" ")
    var mapLocationCenter = PropertyPackage(CLLocation())
    
    let currentTemperature = PropertyPackage(" ")
    let currentCondition = PropertyPackage(" ")
    let conditionDescription = PropertyPackage(" ")
    var weatherImage = PropertyPackage(UIImage())
    
    let feelsLikeInfo = PropertyPackage(" ")
    let pressureInfo = PropertyPackage(" ")
    let humidityInfo = PropertyPackage(" ")
    
    let windSpeedInfo = PropertyPackage(" ")
    let visibilityInfo = PropertyPackage(" ")
    let cloudinessInfo = PropertyPackage(" ")
    
    let sunRiseInfo = PropertyPackage(" ")
    let sunSetInfo = PropertyPackage(" ")
    
    init( weatherQueryController : WeatherQueryController ) {
        self.weatherQueryController = weatherQueryController
    }
    
    func searchCityInfo( searchStr : String, completionHandler: @escaping ([LocationData]?) -> Void ) {
        weatherQueryController.queryCityWeatherInfo(searchStr: searchStr) {
            locationsData, weatherData in
            
            if (locationsData == nil && weatherData == nil) || (locationsData != nil && locationsData!.count == 0) {
                self.resetPropertyValues()
                completionHandler(nil)
            } else if weatherData == nil && locationsData!.count > 1 {
                completionHandler(locationsData)
            } else if locationsData != nil && weatherData != nil {
                self.weatherData = weatherData
                self.locationData = locationsData![0]
                self.updatePropertyValues()
                completionHandler(locationsData)
            }
        }
    }
    
    func searchCityInfo( latitude : Double, longitude : Double, completionHandler: @escaping ([LocationData]?) -> Void ) {
        weatherQueryController.queryCityWeatherInfoReverse(latitude: latitude, longitude: longitude) {
            locationsData, weatherData in
            
            if (locationsData == nil && weatherData == nil) || (locationsData != nil && locationsData!.count == 0) {
                self.resetPropertyValues()
                completionHandler(nil)
            } else if weatherData == nil && locationsData!.count > 1 {
                completionHandler(locationsData)
            } else if locationsData != nil && weatherData != nil {
                self.weatherData = weatherData
                self.locationData = locationsData![0]
                self.updatePropertyValues()
                completionHandler(locationsData)
            }
        }
    }
    private func updatePropertyValues() {
        guard let locationData = self.locationData, let weatherData = self.weatherData else { return }
        self.mapLocationCenter.value = CLLocation(latitude: weatherData.coordinates.lat, longitude: weatherData.coordinates.lon)
        
        self.locationName.value = locationData.name + " " + locationData.state + " " + locationData.country
        
        if weatherData.currentWeather[0].icon != nil {
            self.weatherImage.value = weatherData.currentWeather[0].icon!
        }
        self.currentTemperature.value = String(format: "%.2f", 9 * (weatherData.temperatueParameters.temperature - 273) / 5 + 32) + "\u{00B0} F"
        self.currentCondition.value = weatherData.currentWeather[0].parameter
        self.conditionDescription.value = weatherData.currentWeather[0].description
        
        self.feelsLikeInfo.value = String(format: "%.2f", 9 * (weatherData.temperatueParameters.feelsLike - 273) / 5 + 32) + "\u{00B0} F"
        self.pressureInfo.value = String(weatherData.temperatueParameters.pressure) + " hPa"
        self.humidityInfo.value = String(weatherData.temperatueParameters.humidity) + " %" // Would have used localization with more time.
        
        self.windSpeedInfo.value = String(weatherData.windParameters.speed) + " m/s"
        if weatherData.visibility >= 1000 {
            self.visibilityInfo.value = String(weatherData.visibility / 1000) + "." + String(weatherData.visibility % 1000) + "km"
        } else {
            self.visibilityInfo.value = String(weatherData.visibility) + " m"
        }
        
        self.cloudinessInfo.value = String(weatherData.cloudParameters.cloudiness) + " %"
        
        let sunriseTime = Date(timeIntervalSince1970: TimeInterval(weatherData.sysParameters.sunrise))
        let sunsetTime = Date(timeIntervalSince1970: TimeInterval(weatherData.sysParameters.sunset))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "hh:mm a"
        
        self.sunRiseInfo.value = dateFormatter.string(from: sunriseTime)
        self.sunSetInfo.value = dateFormatter.string(from: sunsetTime)
    }
    
    private func resetPropertyValues() {
        self.mapLocationCenter.value = CLLocation()
        self.locationName.value = "Unknown"
        self.weatherImage.value = UIImage()
        self.currentTemperature.value = " "
        self.currentCondition.value = " "
        self.conditionDescription.value = " "
        
        self.feelsLikeInfo.value = " "
        self.pressureInfo.value = " "
        self.humidityInfo.value = " "
        
        self.windSpeedInfo.value = " "
        self.visibilityInfo.value = " "
        self.cloudinessInfo.value = " "
        
        self.sunRiseInfo.value = " "
        self.sunSetInfo.value = " "
    }
}
