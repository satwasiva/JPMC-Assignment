//
//  AppScopeDependencyContainer.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 3/29/23.
//

import Foundation

class AppScopeDependencyContainer {
    static let shared = AppScopeDependencyContainer()
    
    let sharedDataSource : DataSourceProtocol
    let networkingService = NetworkQueryService()
    let imageCache = ImageCache(memoryLimit: 1024*1024*100)
    
    private init() {
        sharedDataSource = DataSource(sourceType: .networkLocation)
    }
    
    func makeDataSource( ofType sourceType : ContentSourceType ) -> DataSourceProtocol {
        return DataSource(sourceType: sourceType)
    }
}
