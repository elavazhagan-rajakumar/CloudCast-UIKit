//
//  ForecastCell.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//

import UIKit

// MARK: - Single day forecast card in the horizontal scroll
final class ForecastCell: UICollectionViewCell {

    static let reuseID = "ForecastCell"

    // MARK: - UI
    private let dayLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let highLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let lowLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
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
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        contentView.layer.cornerRadius = 14

        let stack = UIStackView(arrangedSubviews: [
            dayLabel, iconImageView, highLabel, lowLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    // MARK: - Configure
    func configure(with forecast: DayForecast) {
        dayLabel.text = forecast.day
        highLabel.text = forecast.high
        lowLabel.text  = forecast.low

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconImageView.image = UIImage(
            systemName: forecast.conditionIcon,
            withConfiguration: config
        )
    }
}
