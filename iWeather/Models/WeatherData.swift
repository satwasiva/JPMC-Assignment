//
//  WeatherData.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation
import UIKit.UIImage

struct WeatherData : Decodable {
    let readingTime : UInt64
    let visibility : UInt16
    let timezoneDiff : Int64
    let coordinates : Coordinates
    var currentWeather : [CurrentWeather]
    let temperatueParameters : TemperatureParameters
    let windParameters : WindParameters
    let cloudParameters : CloudParameters
    let rainInfo : RainInformation?
    let snowInfo : SnowInformation?
    let sysParameters : DaySysParameters
    
    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coordinates = try container.decode(Coordinates.self, forKey: .coord)
        self.currentWeather = try container.decode([CurrentWeather].self, forKey: .weather)
        self.temperatueParameters = try container.decode(TemperatureParameters.self, forKey: .main)
        self.visibility = try container.decode(UInt16.self, forKey: .visibility)
        self.windParameters = try container.decode(WindParameters.self, forKey: .wind)
        self.cloudParameters = try container.decode(CloudParameters.self, forKey: .clouds)
        self.rainInfo = try container.decodeIfPresent(RainInformation.self, forKey: .rain)
        self.snowInfo = try container.decodeIfPresent(SnowInformation.self, forKey: .snow)
        self.readingTime = try container.decode(UInt64.self, forKey: .dt)
        self.sysParameters = try container.decode(DaySysParameters.self, forKey: .sys)
        self.timezoneDiff = try container.decode(Int64.self, forKey: .timezone)
    }
    
    enum CodingKeys: String, CodingKey {
        case coord, weather, main, visibility, wind
        case clouds, rain, snow, dt, sys, timezone
    }
}

extension WeatherData {
    struct Coordinates : Decodable {
        let lat : Double
        let lon : Double
        
        enum CodingKeys: String, CodingKey {
            case lon, lat
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let lat = try container.decode(Double.self, forKey: .lat)
            self.lat = Double(round(100 * lat) / 100)
            let lon = try container.decode(Double.self, forKey: .lon)
            self.lon = Double(round(100 * lon) / 100)
        }
    }
}

extension WeatherData {
    struct CurrentWeather : Decodable {
        let conditionId : UInt16
        
        // This parameter could be enum had the API gave all the possible values
        // for main key of weather key.
        let parameter : String
        
        let description : String
        let iconId : String
        var icon : UIImage?
        
        enum CodingKeys: String, CodingKey {
            case id, main, description, icon
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.conditionId = try container.decode(UInt16.self, forKey: .id)
            self.parameter = try container.decode(String.self, forKey: .main)
            self.description = try container.decode(String.self, forKey: .description)
            self.iconId = try container.decode(String.self, forKey: .icon)
        }
    }
}

extension WeatherData {
    struct TemperatureParameters : Decodable {
        let temperature : Double
        let feelsLike : Double
        let pressure : Double
        let humidity : Double
        let minNoted : Double
        let maxNoted : Double
        let seaLevelPressure : Double?
        let groundPressure : Double?
        
        enum CodingKeys: String, CodingKey {
            case temp, feels_like, pressure, humidity, temp_min, temp_max, sea_level, grnd_level
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.temperature = try container.decode(Double.self, forKey: .temp)
            self.feelsLike = try container.decode(Double.self, forKey: .feels_like)
            self.pressure = try container.decode(Double.self, forKey: .pressure)
            self.humidity = try container.decode(Double.self, forKey: .humidity)
            self.minNoted = try container.decode(Double.self, forKey: .temp_min)
            self.maxNoted = try container.decode(Double.self, forKey: .temp_max)
            self.seaLevelPressure = try container.decodeIfPresent(Double.self, forKey: .sea_level)
            self.groundPressure = try container.decodeIfPresent(Double.self, forKey: .grnd_level)
        }
    }
}

extension WeatherData {
    struct WindParameters : Decodable {
        let speed : Double
        let direction : Double
        let gust : Double?
        
        enum CodingKeys: String, CodingKey {
            case speed, deg, gust
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.speed = try container.decode(Double.self, forKey: .speed)
            self.direction = try container.decode(Double.self, forKey: .deg)
            self.gust = try container.decodeIfPresent(Double.self, forKey: .gust)
        }
    }
}

extension WeatherData {
    struct CloudParameters : Decodable {
        let cloudiness : Double
        
        enum CodingKeys: String, CodingKey {
            case all
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.cloudiness = try container.decode(Double.self, forKey: .all)
        }
    }
}

extension WeatherData {
    struct RainInformation : Decodable {
        let oneHourRainfall : Double?
        let threeHourRainfall : Double?
        
        private enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
            case threeHour = "3h"
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.oneHourRainfall = try container.decodeIfPresent(Double.self, forKey: .oneHour)
            self.threeHourRainfall = try container.decodeIfPresent(Double.self, forKey: .threeHour)
            
        }
    }
}

extension WeatherData {
    struct SnowInformation : Decodable {
        let oneHourSnowfall : Double?
        let threeHOurSnowfall : Double?
        
        private enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
            case threeHour = "3h"
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.oneHourSnowfall = try container.decodeIfPresent(Double.self, forKey: .oneHour)
            self.threeHOurSnowfall = try container.decodeIfPresent(Double.self, forKey: .threeHour)
            
        }
    }
}

extension WeatherData {
    struct DaySysParameters : Decodable {
        let country : String
        let sunrise : UInt32
        let sunset : UInt32
        
        enum CodingKeys: String, CodingKey {
            case country, sunrise, sunset
        }
        
        init(from decoder : Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.country = try container.decode(String.self, forKey: .country)
            self.sunrise = try container.decode(UInt32.self, forKey: .sunrise)
            self.sunset = try container.decode(UInt32.self, forKey: .sunset)
        }
    }
}
