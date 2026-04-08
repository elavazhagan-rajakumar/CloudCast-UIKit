//
//  StatTileView.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 08/04/26.
//

import UIKit

// MARK: - Reusable tile for Wind, Humidity, UV, Visibility
final class StatTileView: UIView {

    // MARK: - UI
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let unitLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
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
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 4
        headerStack.alignment = .center

        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 2
        valueStack.alignment = .lastBaseline

        let mainStack = UIStackView(arrangedSubviews: [headerStack, valueStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    // MARK: - Configure
    func configure(icon: String, title: String, value: String, unit: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        titleLabel.text = title.uppercased()
        valueLabel.text = value
        unitLabel.text  = unit
    }
}
