//
//  WeatherDependencyContainer.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation

class WeatherDependencyContainer {
    static let shared = WeatherDependencyContainer()
    
    let appScopeDependencyContainer = AppScopeDependencyContainer.shared
    
    let curWeatherInfoVM : SearchCurrentWeatherInfoViewModel
    let weatherQueryController : WeatherQueryController
    
    private init() {
        weatherQueryController = WeatherQueryController( dataSourcer: appScopeDependencyContainer.sharedDataSource, imgCache: appScopeDependencyContainer.imageCache)
        
        curWeatherInfoVM = SearchCurrentWeatherInfoViewModel(weatherQueryController: weatherQueryController)
    }
    
    func makeSearchCurWeatherInfoVM( weatherQueryController : WeatherQueryController ) -> SearchCurrentWeatherInfoViewModel{
        return SearchCurrentWeatherInfoViewModel(weatherQueryController: weatherQueryController)
    }
}
