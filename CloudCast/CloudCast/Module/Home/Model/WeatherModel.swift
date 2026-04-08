//
//  WeatherModel.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//

import Foundation

// MARK: - Current Weather Response
// Maps exactly to OpenWeatherMap /weather API JSON
struct WeatherResponse: Decodable {
    let name: String           // city name
    let main: MainWeather
    let weather: [WeatherInfo]
    let wind: Wind
    let visibility: Int?
    let sys: Sys
}

struct MainWeather: Decodable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin    = "temp_min"
        case tempMax    = "temp_max"
        case humidity
        case pressure
    }
}

struct WeatherInfo: Decodable {
    let id: Int
    let main: String        // "Rain", "Clear", "Clouds" etc.
    let description: String // "light rain", "clear sky" etc.
    let icon: String        // "10d", "01n" etc.
}

struct Wind: Decodable {
    let speed: Double
}

struct Sys: Decodable {
    let country: String?
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
}

// MARK: - Forecast Response
// Maps to OpenWeatherMap /forecast API JSON
struct ForecastResponse: Decodable {
    let list: [ForecastItem]
    let city: ForecastCity
}

struct ForecastCity: Decodable {
    let name: String
    let country: String
}

struct ForecastItem: Decodable {
    let dt: TimeInterval           // Unix timestamp
    let main: MainWeather
    let weather: [WeatherInfo]
    let wind: Wind
    let dtTxt: String              // "2024-03-20 12:00:00"

    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case wind
        case dtTxt = "dt_txt"
    }
}

// MARK: - Display Model (what the ViewModel prepares for the View)
// Raw API data → clean display model
// ViewController only ever sees this, never raw API structs
struct WeatherDisplayModel {
    let cityName: String
    let countryCode: String
    let temperature: String        // "24°"
    let feelsLike: String
    let condition: String          // "Partly Cloudy"
    let conditionIcon: String      // SF Symbol name
    let high: String               // "↑ 27°"
    let low: String                // "↓ 18°"
    let humidity: String           // "76%"
    let windSpeed: String          // "3 mph"
    let visibility: String         // "2 km"
    let uvIndex: String            // placeholder on free plan
    let forecast: [DayForecast]
}

struct DayForecast {
    let day: String                // "WED", "THU" etc.
    let conditionIcon: String      // SF Symbol name
    let high: String
    let low: String
}
