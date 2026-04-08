//
//  HomeViewController.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//
import UIKit

final class HomeViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: HomeViewModel

    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let locationButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "location.fill")
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .label
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cityNameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let conditionSubtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let weatherCard = WeatherCardView()

    // Forecast collection view
    private lazy var forecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: 130)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(ForecastCell.self, forCellWithReuseIdentifier: ForecastCell.reuseID)
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let forecastTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "5 DAY FORECAST"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Stat tiles
    private let windTile       = StatTileView()
    private let humidityTile   = StatTileView()
    private let uvTile         = StatTileView()
    private let visibilityTile = StatTileView()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Drives the forecast collection view
    private var forecastData: [DayForecast] = []

    // MARK: - Init
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadWeather()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.89, green: 0.93, blue: 0.97, alpha: 1)
        setupScrollView()
        setupLocationButton()
        setupCityHeader()
        setupWeatherCard()
        setupForecast()
        setupStatTiles()
        setupLoadingAndError()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    private func setupLocationButton() {
        contentView.addSubview(locationButton)
        locationButton.addTarget(
            self,
            action: #selector(locationTapped),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 16),
            locationButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            locationButton.widthAnchor.constraint(equalToConstant: 44),
            locationButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func setupCityHeader() {
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(conditionSubtitleLabel)

        NSLayoutConstraint.activate([
            cityNameLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 20),
            cityNameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            cityNameLabel.trailingAnchor.constraint(
                equalTo: locationButton.leadingAnchor, constant: -8),

            conditionSubtitleLabel.topAnchor.constraint(
                equalTo: cityNameLabel.bottomAnchor, constant: 2),
            conditionSubtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
        ])
    }

    private func setupWeatherCard() {
        contentView.addSubview(weatherCard)

        NSLayoutConstraint.activate([
            weatherCard.topAnchor.constraint(
                equalTo: conditionSubtitleLabel.bottomAnchor, constant: 16),
            weatherCard.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            weatherCard.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    private func setupForecast() {
        contentView.addSubview(forecastTitleLabel)
        contentView.addSubview(forecastCollectionView)

        NSLayoutConstraint.activate([
            forecastTitleLabel.topAnchor.constraint(
                equalTo: weatherCard.bottomAnchor, constant: 24),
            forecastTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),

            forecastCollectionView.topAnchor.constraint(
                equalTo: forecastTitleLabel.bottomAnchor, constant: 10),
            forecastCollectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor),
            forecastCollectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 130),
        ])
    }

    private func setupStatTiles() {
        // Configure tile content
        windTile.configure(
            icon: "wind", title: "Wind",
            value: "--", unit: "km/h")
        humidityTile.configure(
            icon: "humidity", title: "Humidity",
            value: "--", unit: "%")
        uvTile.configure(
            icon: "sun.max", title: "UV Index",
            value: "--", unit: "")
        visibilityTile.configure(
            icon: "eye", title: "Visibility",
            value: "--", unit: "km")

        // 2x2 grid using two horizontal stacks
        let topRow = UIStackView(arrangedSubviews: [windTile, humidityTile])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.distribution = .fillEqually

        let bottomRow = UIStackView(arrangedSubviews: [uvTile, visibilityTile])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 12
        bottomRow.distribution = .fillEqually

        let grid = UIStackView(arrangedSubviews: [topRow, bottomRow])
        grid.axis = .vertical
        grid.spacing = 12
        grid.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(grid)

        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(
                equalTo: forecastCollectionView.bottomAnchor, constant: 20),
            grid.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            grid.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -24),
            topRow.heightAnchor.constraint(equalToConstant: 90),
            bottomRow.heightAnchor.constraint(equalToConstant: 90),
        ])
    }

    private func setupLoadingAndError() {
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
    }

    // MARK: - Render
    private func render(state: HomeViewState) {
        switch state {
        case .idle:
            break

        case .loading:
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            scrollView.isHidden = true

        case .success(let model):
            activityIndicator.stopAnimating()
            errorLabel.isHidden = true
            scrollView.isHidden = false
            populate(with: model)

        case .failure(let message):
            activityIndicator.stopAnimating()
            scrollView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = message
        }
    }

    // MARK: - Populate UI with data
    private func populate(with model: WeatherDisplayModel) {
        cityNameLabel.text         = "\(model.cityName), \(model.countryCode)"
        conditionSubtitleLabel.text = model.condition
        weatherCard.configure(with: model)

        windTile.configure(
            icon: "wind", title: "Wind",
            value: model.windSpeed.components(separatedBy: " ").first ?? "--",
            unit: "km/h"
        )
        humidityTile.configure(
            icon: "humidity.fill", title: "Humidity",
            value: model.humidity.replacingOccurrences(of: "%", with: ""),
            unit: "%"
        )
        uvTile.configure(
            icon: "sun.max.fill", title: "UV Index",
            value: "2", unit: "Low"
        )
        visibilityTile.configure(
            icon: "eye.fill", title: "Visibility",
            value: model.visibility.components(separatedBy: " ").first ?? "--",
            unit: "km"
        )

        forecastData = model.forecast
        forecastCollectionView.reloadData()
    }

    // MARK: - Actions
    @objc private func locationTapped() {
        viewModel.loadWeather()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        forecastData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ForecastCell.reuseID,
            for: indexPath
        ) as! ForecastCell

        cell.configure(with: forecastData[indexPath.item])
        return cell
    }
}
