//
//  WeatherServices.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import Foundation
import CoreLocation

// MARK: - Errors
enum WeatherError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(String)
    case networkFailed(String)
    case invalidAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "Invalid request URL."
        case .noData:                  return "No weather data received."
        case .decodingFailed(let m):   return "Data error: \(m)"
        case .networkFailed(let m):    return "Network error: \(m)"
        case .invalidAPIKey:           return "Invalid API key."
        }
    }
}

// MARK: - Protocol
protocol WeatherServiceProtocol {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse
    func fetchCurrentWeatherByCity(_ city: String) async throws -> WeatherResponse
    func fetchForecastByCity(_ city: String) async throws -> ForecastResponse
}

// MARK: - Implementation
final class WeatherService: WeatherServiceProtocol {

    // Your OpenWeatherMap API key
    private let apiKey = "a95d0244a8462b54bbbac40709e153a8"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let units = "metric"    // Celsius — toggle via Settings later

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // MARK: - By coordinates (used with CoreLocation)
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=\(units)"
        return try await fetch(urlString: urlString)
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=\(units)"
        return try await fetch(urlString: urlString)
    }

    // MARK: - By city name (used from Search screen)
    func fetchCurrentWeatherByCity(_ city: String) async throws -> WeatherResponse {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)/weather?q=\(encoded)&appid=\(apiKey)&units=\(units)"
        return try await fetch(urlString: urlString)
    }

    func fetchForecastByCity(_ city: String) async throws -> ForecastResponse {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseURL)/forecast?q=\(encoded)&appid=\(apiKey)&units=\(units)"
        return try await fetch(urlString: urlString)
    }

    // MARK: - Generic fetch (used by all above methods)
    private func fetch<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse else {
                throw WeatherError.noData
            }

            switch http.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch let error as DecodingError {
                    throw WeatherError.decodingFailed(error.localizedDescription)
                }
            case 401:
                throw WeatherError.invalidAPIKey
            default:
                throw WeatherError.networkFailed("Status code: \(http.statusCode)")
            }

        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkFailed(error.localizedDescription)
        }
    }
}
