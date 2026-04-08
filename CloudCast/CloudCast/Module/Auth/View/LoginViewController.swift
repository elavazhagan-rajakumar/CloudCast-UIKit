//
//  LoginViewController.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//
import UIKit

final class LoginViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: LoginViewModel

    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cloud.sun.fill")
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Cloudcast"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "ATMOSPHERIC FORECAST"
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emailLabel = AuthUI.fieldLabel("Email Address")
    private let emailTextField = AuthUI.textField(
        placeholder: "you@example.com",
        icon: "envelope",
        keyboardType: .emailAddress
    )

    private let passwordLabel = AuthUI.fieldLabel("Password")
    private let passwordTextField = AuthUI.textField(
        placeholder: "Password",
        icon: "lock",
        isSecure: true
    )

    private lazy var passwordEyeButton = AuthUI.eyeButton(targeting: passwordTextField)

    private let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.image = UIImage(systemName: "arrow.right")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor(red: 0.36, green: 0.58, blue: 0.93, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .systemRed
        l.font = .systemFont(ofSize: 13)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        let base = NSMutableAttributedString(
            string: "Don't have an account?  ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        base.append(NSAttributedString(
            string: "Sign up",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.systemBlue
            ]
        ))
        btn.setAttributedTitle(base, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Tracks which field has a red border right now
    private weak var highlightedField: UITextField?

    // MARK: - Init
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
        registerKeyboardNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.89, green: 0.93, blue: 0.97, alpha: 1)

        passwordTextField.rightView = passwordEyeButton
        passwordTextField.rightViewMode = .always

        // Main vertical stack
        let stack = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            subtitleLabel,
            emailLabel,
            emailTextField,
            passwordLabel,
            passwordTextField,
            loginButton,
            errorLabel,
            signUpButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(4,  after: emailLabel)
        stack.setCustomSpacing(4,  after: passwordLabel)
        stack.setCustomSpacing(20, after: subtitleLabel)
        stack.setCustomSpacing(20, after: passwordTextField)
        stack.setCustomSpacing(8,  after: loginButton)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)
        cardView.addSubview(stack)

        let fieldWidth = stack.widthAnchor

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
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),

            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            emailTextField.widthAnchor.constraint(equalTo: fieldWidth),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.widthAnchor.constraint(equalTo: fieldWidth),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
            loginButton.widthAnchor.constraint(equalTo: fieldWidth),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            errorLabel.widthAnchor.constraint(equalTo: fieldWidth),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(emailChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
        
        viewModel.onValidationError = { [weak self] error in
            DispatchQueue.main.async { self?.renderValidationError(error) }
        }
    }

    // MARK: - Render
    private func render(state: AuthViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            errorLabel.text = ""

        case .loading:
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
            errorLabel.text = ""
            clearFieldHighlight()

        case .success:
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            navigateToHome()

        case .failure(let message):
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            errorLabel.text = message
        }
    }

    private func renderValidationError(_ error: AuthValidationError?) {
        clearFieldHighlight()
        guard let error else {
            errorLabel.text = ""
            return
        }
        errorLabel.text = error.message
        let field = error.field == .email ? emailTextField : passwordTextField
        highlight(field: field)
        field.becomeFirstResponder()
    }

    private func highlight(field: UITextField) {
        highlightedField = field
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.systemRed.cgColor
        field.layer.cornerRadius = 10
    }

    private func clearFieldHighlight() {
        highlightedField?.layer.borderWidth = 0
        highlightedField?.layer.borderColor = UIColor.clear.cgColor
        highlightedField = nil
    }

    // MARK: - Navigation
    private func navigateToHome() {
        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }

    // MARK: - Selectors
    @objc private func loginTapped() {
        view.endEditing(true)
        viewModel.login()
    }

    @objc private func signUpTapped() {
        let vc = SignUpViewController()
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    @objc private func emailChanged(_ tf: UITextField) {
        viewModel.emailChanged(tf.text ?? "")
    }

    @objc private func passwordChanged(_ tf: UITextField) {
        viewModel.passwordChanged(tf.text ?? "")
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let inset = frame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = inset
            self.scrollView.verticalScrollIndicatorInsets.bottom = inset
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            viewModel.login()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == highlightedField {
            clearFieldHighlight()
            errorLabel.text = ""
        }
    }
}
