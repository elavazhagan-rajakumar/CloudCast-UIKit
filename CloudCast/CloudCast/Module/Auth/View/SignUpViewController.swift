//
//  SignUpViewController.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//
import UIKit

final class SignUpViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: SignUpViewModel

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
        iv.image = UIImage(systemName: "person.badge.plus")
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Create Account"
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Join Cloudcast today"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let fullNameLabel  = AuthUI.fieldLabel("Full Name")
    private let emailLabel     = AuthUI.fieldLabel("Email Address")
    private let passwordLabel  = AuthUI.fieldLabel("Password")
    private let confirmLabel   = AuthUI.fieldLabel("Confirm Password")

    private let fullNameTextField = AuthUI.textField(
        placeholder: "John Doe",
        icon: "person",
        autocapitalize: .words
    )
    private let emailTextField = AuthUI.textField(
        placeholder: "you@example.com",
        icon: "envelope",
        keyboardType: .emailAddress
    )
    private let passwordTextField = AuthUI.textField(
        placeholder: "Min 8 chars, 1 uppercase, 1 number",
        icon: "lock",
        isSecure: true
    )
    private let confirmPasswordTextField = AuthUI.textField(
        placeholder: "Re-enter password",
        icon: "lock",
        isSecure: true
    )

    private lazy var passwordEyeButton = AuthUI.eyeButton(targeting: passwordTextField)
    private lazy var confirmEyeButton  = AuthUI.eyeButton(targeting: confirmPasswordTextField)

    private let createButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Create Account"
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

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        let base = NSMutableAttributedString(
            string: "Already have an account?  ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        base.append(NSAttributedString(
            string: "Login",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.systemBlue
            ]
        ))
        btn.setAttributedTitle(base, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private weak var highlightedField: UITextField?

    // MARK: - Init
    init(viewModel: SignUpViewModel = SignUpViewModel()) {
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
        confirmPasswordTextField.rightView = confirmEyeButton
        confirmPasswordTextField.rightViewMode = .always

        let stack = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            subtitleLabel,
            fullNameLabel,  fullNameTextField,
            emailLabel,     emailTextField,
            passwordLabel,  passwordTextField,
            confirmLabel,   confirmPasswordTextField,
            createButton,
            errorLabel,
            loginButton,
            activityIndicator
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(4,  after: fullNameLabel)
        stack.setCustomSpacing(4,  after: emailLabel)
        stack.setCustomSpacing(4,  after: passwordLabel)
        stack.setCustomSpacing(4,  after: confirmLabel)
        stack.setCustomSpacing(20, after: subtitleLabel)
        stack.setCustomSpacing(20, after: confirmPasswordTextField)
        stack.setCustomSpacing(8,  after: createButton)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)
        cardView.addSubview(stack)

        let fw = stack.widthAnchor

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

            fullNameTextField.heightAnchor.constraint(equalToConstant: 48),
            fullNameTextField.widthAnchor.constraint(equalTo: fw),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            emailTextField.widthAnchor.constraint(equalTo: fw),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.widthAnchor.constraint(equalTo: fw),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 48),
            confirmPasswordTextField.widthAnchor.constraint(equalTo: fw),
            createButton.heightAnchor.constraint(equalToConstant: 52),
            createButton.widthAnchor.constraint(equalTo: fw),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            errorLabel.widthAnchor.constraint(equalTo: fw),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        fullNameTextField.addTarget(self,
            action: #selector(fullNameChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self,
            action: #selector(emailChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self,
            action: #selector(passwordChanged(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self,
            action: #selector(confirmChanged(_:)), for: .editingChanged)

        [fullNameTextField, emailTextField,
         passwordTextField, confirmPasswordTextField].forEach { $0.delegate = self }

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
            createButton.isEnabled = true
            errorLabel.text = ""

        case .loading:
            activityIndicator.startAnimating()
            createButton.isEnabled = false
            errorLabel.text = ""
            clearFieldHighlight()

        case .success:
            activityIndicator.stopAnimating()
            createButton.isEnabled = true
            navigateToHome()

        case .failure(let message):
            activityIndicator.stopAnimating()
            createButton.isEnabled = true
            errorLabel.text = message
        }
    }

    private func renderValidationError(_ error: AuthValidationError?) {
        clearFieldHighlight()
        guard let error else { errorLabel.text = ""; return }

        errorLabel.text = error.message

        let field: UITextField = {
            switch error.field {
            case .fullName:        return fullNameTextField
            case .email:           return emailTextField
            case .password:        return passwordTextField
            case .confirmPassword: return confirmPasswordTextField
            }
        }()

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
    @objc private func createTapped() {
        view.endEditing(true)
        viewModel.signUp()
    }

    @objc private func loginTapped() {
        dismiss(animated: true)
    }

    @objc private func fullNameChanged(_ tf: UITextField) {
        viewModel.fullNameChanged(tf.text ?? "")
    }

    @objc private func emailChanged(_ tf: UITextField) {
        viewModel.emailChanged(tf.text ?? "")
    }

    @objc private func passwordChanged(_ tf: UITextField) {
        viewModel.passwordChanged(tf.text ?? "")
    }

    @objc private func confirmChanged(_ tf: UITextField) {
        viewModel.confirmPasswordChanged(tf.text ?? "")
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
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameTextField:          emailTextField.becomeFirstResponder()
        case emailTextField:             passwordTextField.becomeFirstResponder()
        case passwordTextField:          confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:   textField.resignFirstResponder(); viewModel.signUp()
        default:                         textField.resignFirstResponder()
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
