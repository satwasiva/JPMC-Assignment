//
//  AppScopeDependencyContainer.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation

class AppScopeDependencyContainer {
    static let shared = AppScopeDependencyContainer()
    
    let sharedDataSource : DataSourceProtocol
    let networkingService = NetworkQueryService()
    let imageCache = ImageCache(memoryLimit: 1024*1024*100)
    
    private init() {
        sharedDataSource = DataSourceFromNetwork()
    }
    
    func makeDataSource( ofType sourceType : ContentSourceType ) -> DataSourceProtocol {
        return DataSourceWithLocalJSON()
    }
}
