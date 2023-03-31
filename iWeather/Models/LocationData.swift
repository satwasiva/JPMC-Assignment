//
//  LocationData.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation

struct LocationData : Decodable {
    let name : String
    let lat : Double
    let lon : Double
    let country : String
    let state : String
    
    enum CodingKeys: String, CodingKey {
        case name
        case lat
        case lon
        case country
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        let lat = try container.decode(Double.self, forKey: .lat)
        self.lat = Double(round(100 * lat) / 100)
        let lon = try container.decode(Double.self, forKey: .lon)
        self.lon = Double(round(100 * lon) / 100)
        self.country = try container.decode(String.self, forKey: .country)
        self.state = try container.decode(String.self, forKey: .state)
    }
}

