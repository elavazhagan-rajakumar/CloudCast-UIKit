//
//  WeatherCardView.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//

import UIKit

// MARK: - The main weather card shown at the top of Home screen
final class WeatherCardView: UIView {

    // MARK: - UI Elements
    private let conditionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 1.0, green: 0.72, blue: 0.2, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 72, weight: .thin)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let highLowLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            conditionImageView,
            temperatureLabel,
            conditionLabel,
            highLowLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.setCustomSpacing(12, after: conditionImageView)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            conditionImageView.widthAnchor.constraint(equalToConstant: 80),
            conditionImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    // MARK: - Configure (called by ViewController with display model)
    func configure(with model: WeatherDisplayModel) {
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .medium)
        conditionImageView.image = UIImage(
            systemName: model.conditionIcon,
            withConfiguration: config
        )
        temperatureLabel.text = model.temperature
        conditionLabel.text   = model.condition
        highLowLabel.text     = "\(model.high)  •  \(model.low)"
    }
}
