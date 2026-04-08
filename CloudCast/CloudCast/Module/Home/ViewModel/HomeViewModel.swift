//
//  HomeViewModel.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//

import Foundation
import CoreLocation

// MARK: - View state
enum HomeViewState {
    case idle
    case loading
    case success(WeatherDisplayModel)
    case failure(String)
}

// MARK: - ViewModel
final class HomeViewModel: NSObject {

    // MARK: - Binding
    var onStateChange: ((HomeViewState) -> Void)?

    // MARK: - Private
    private let weatherService: WeatherServiceProtocol
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    private var state: HomeViewState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onStateChange?(self.state)
            }
        }
    }

    // MARK: - Init
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
        super.init()
        setupLocationManager()
    }

    // MARK: - Location setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Called by ViewController on viewDidLoad
    func loadWeather() {
        state = .loading
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Fall back to default city if location denied
            fetchWeatherForDefaultCity()
        @unknown default:
            fetchWeatherForDefaultCity()
        }
    }

    // MARK: - Fetch by coordinates
    private func fetchWeather(lat: Double, lon: Double) {
        Task {
            do {
                async let weatherTask  = weatherService.fetchCurrentWeather(lat: lat, lon: lon)
                async let forecastTask = weatherService.fetchForecast(lat: lat, lon: lon)

                // Both calls run in parallel
                let (weather, forecast) = try await (weatherTask, forecastTask)
                let displayModel = buildDisplayModel(weather: weather, forecast: forecast)
                state = .success(displayModel)

            } catch let error as WeatherError {
                state = .failure(error.errorDescription ?? "Something went wrong.")
            } catch {
                state = .failure("Could not load weather. Please try again.")
            }
        }
    }

    // MARK: - Fallback city
    private func fetchWeatherForDefaultCity() {
        Task {
            do {
                async let weatherTask  = weatherService.fetchCurrentWeatherByCity("Delhi")
                async let forecastTask = weatherService.fetchForecastByCity("Delhi")

                let (weather, forecast) = try await (weatherTask, forecastTask)
                let displayModel = buildDisplayModel(weather: weather, forecast: forecast)
                state = .success(displayModel)

            } catch let error as WeatherError {
                state = .failure(error.errorDescription ?? "Something went wrong.")
            } catch {
                state = .failure("Could not load weather. Please try again.")
            }
        }
    }

    // MARK: - Build display model from raw API data
    // This is the most important method — converts messy API data
    // into clean, pre-formatted strings ready for the View to display
    private func buildDisplayModel(
        weather: WeatherResponse,
        forecast: ForecastResponse
    ) -> WeatherDisplayModel {

        let country = weather.sys.country ?? ""
        let temp    = Int(weather.main.temp.rounded())
        let high    = Int(weather.main.tempMax.rounded())
        let low     = Int(weather.main.tempMin.rounded())
        let condition = weather.weather.first?.main ?? "Clear"
        let icon    = weather.weather.first?.icon ?? "01d"

        // Group forecast by day and pick one entry per day
        let dayForecasts = buildDayForecasts(from: forecast.list)

        return WeatherDisplayModel(
            cityName:      weather.name,
            countryCode:   country,
            temperature:   "\(temp)°",
            feelsLike:     "\(temp)°",
            condition:     condition,
            conditionIcon: sfSymbol(for: icon),
            high:          "↑ \(high)°",
            low:           "↓ \(low)°",
            humidity:      "\(weather.main.humidity)%",
            windSpeed:     "\(Int(weather.wind.speed.rounded())) km/h",
            visibility:    weather.visibility.map { "\($0 / 1000) km" } ?? "--",
            uvIndex:       "2 Low",    // not available on free plan
            forecast:      dayForecasts
        )
    }

    // Groups 3-hourly forecast items into one entry per day
    private func buildDayForecasts(from items: [ForecastItem]) -> [DayForecast] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Group items by day string "2024-03-20"
        var grouped: [(day: String, items: [ForecastItem])] = []
        var seen: [String: Int] = [:]

        for item in items {
            let dayKey = String(item.dtTxt.prefix(10))  // "2024-03-20"
            if let idx = seen[dayKey] {
                grouped[idx].items.append(item)
            } else {
                seen[dayKey] = grouped.count
                grouped.append((day: dayKey, items: [item]))
            }
        }

        // Skip today (index 0), take next 5 days
        return grouped.prefix(6).dropFirst().map { group in
            let highs = group.items.map { $0.main.tempMax }
            let lows  = group.items.map { $0.main.tempMin }
            let icon  = group.items.first?.weather.first?.icon ?? "01d"

            return DayForecast(
                day:           dayAbbreviation(from: group.day),
                conditionIcon: sfSymbol(for: icon),
                high:          "\(Int((highs.max() ?? 0).rounded()))°",
                low:           "\(Int((lows.min() ?? 0).rounded()))°"
            )
        }
    }

    // "2024-03-20" → "WED"
    private func dayAbbreviation(from dateString: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        guard let date = input.date(from: dateString) else { return "" }

        let output = DateFormatter()
        output.dateFormat = "EEE"
        return output.string(from: date).uppercased()
    }

    // OpenWeatherMap icon code → SF Symbol name
    func sfSymbol(for icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snowflake"
        case "50d", "50n": return "cloud.fog.fill"
        default:            return "cloud.fill"
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        fetchWeather(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude
        )
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        // Location failed — fall back to default city
        fetchWeatherForDefaultCity()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            fetchWeatherForDefaultCity()
        default:
            break
        }
    }
}
