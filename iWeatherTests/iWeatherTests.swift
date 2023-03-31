//
//  iWeatherTests.swift
//  iWeatherTests
//
//  Created by Vamsi Prakhya on 3/27/23.
//

import XCTest
@testable import iWeather

final class iWeatherTests: XCTestCase {

    var dataSource : DataSource? = nil
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDatSourceJSONEnd2End() throws {
        
        let semaphore = DispatchSemaphore(value: 0)
        var weatherInfo : WeatherData? = nil
        var locationInfo : LocationData? = nil
        
        dataSource = DataSource(sourceType: .bundleJSON)
        dataSource!.generateLocationData(city: "Fremont", state: "CA") {
            locationDataList, error in
            
            if locationDataList != nil && locationDataList!.count >= 1 {
                locationInfo = locationDataList![0]
                self.dataSource!.generateWeatherData(currentLocationData: locationDataList![0]) {weatherData,_ in
                    weatherInfo = weatherData
                    semaphore.signal()
                }
            }
        }
        let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(5)
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
                    XCTFail("Test timed out")
                }
        
        XCTAssert(weatherInfo?.coordinates.lat == locationInfo?.lat && weatherInfo?.coordinates.lon == locationInfo?.lon)
    }
    
    func testDatSourceNetworkEnd2EndProperData() throws {
        
        let semaphore = DispatchSemaphore(value: 0)
        var weatherInfo : WeatherData? = nil
        var locationInfo : LocationData? = nil
        var locationCount = 0
        
        dataSource = DataSource(sourceType: .networkLocation)
        dataSource!.generateLocationData(city: "Fremont", state: "CA") {
            locationDataList, error in
            
            if locationDataList != nil && locationDataList!.count >= 1 {
                locationCount = locationDataList!.count
                locationInfo = locationDataList![0]
                self.dataSource!.generateWeatherData(currentLocationData: locationDataList![0]) {weatherData,_ in
                    weatherInfo = weatherData
                    semaphore.signal()
                }
            } else {
                semaphore.signal()
            }
        }
        let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(5)
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
                    XCTFail("Test timed out")
                }
        XCTAssertTrue(locationCount == 1)
        XCTAssert(weatherInfo?.coordinates.lat == locationInfo?.lat && weatherInfo?.coordinates.lon == locationInfo?.lon)
    }

    func testDatSourceNetworkEnd2EndInsufficientData() throws {
        
        let semaphore = DispatchSemaphore(value: 0)
        var weatherInfo : WeatherData? = nil
        var locationInfo : LocationData? = nil
        
        dataSource = DataSource(sourceType: .networkLocation)
        dataSource!.generateLocationData(city: "Fremont", state: "") {
            locationDataList, error in
            
            if locationDataList != nil && locationDataList!.count >= 1 {
                locationInfo = locationDataList![0]
                self.dataSource!.generateWeatherData(currentLocationData: locationDataList![0]) {weatherData,_ in
                    weatherInfo = weatherData
                    semaphore.signal()
                }
            } else {
                semaphore.signal()
            }
        }
        let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(5)
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
                    XCTFail("Test timed out")
                }
        XCTAssert(weatherInfo?.coordinates.lat == locationInfo?.lat && weatherInfo?.coordinates.lon == locationInfo?.lon)
    }
    
    func testDatSourceNetworkEnd2EndBadData() throws {
        
        let semaphore = DispatchSemaphore(value: 0)
        var locationCount = 0
        
        dataSource = DataSource(sourceType: .networkLocation)
        dataSource!.generateLocationData(city: "tghregrgrbno", state: "") {
            locationDataList, error in
            
            if locationDataList != nil {
                locationCount = locationDataList!.count
                semaphore.signal()
            }
        }
        let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(500)
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
                    XCTFail("Test timed out")
                }
        XCTAssertTrue(locationCount == 0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
