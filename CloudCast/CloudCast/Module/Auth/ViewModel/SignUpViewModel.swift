//
//  SignUpViewModel.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//
import Foundation

final class SignUpViewModel {

    // MARK: - Bindings
    var onStateChange: ((AuthViewState) -> Void)?
    var onValidationError: ((AuthValidationError?) -> Void)?

    // MARK: - Private inputs
    private var fullName: String = ""
    private var email: String = ""
    private var password: String = ""
    private var confirmPassword: String = ""

    // MARK: - State
    private var state: AuthViewState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onStateChange?(self.state)
            }
        }
    }

    // MARK: - Dependency injection
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    // MARK: - Input handlers
    func fullNameChanged(_ text: String) {
        fullName = text
        clearValidationError()
    }

    func emailChanged(_ text: String) {
        email = text
        clearValidationError()
    }

    func passwordChanged(_ text: String) {
        password = text
        clearValidationError()
    }

    func confirmPasswordChanged(_ text: String) {
        confirmPassword = text
        clearValidationError()
    }

    // MARK: - Validation
    private func validate() -> AuthValidationError? {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            return AuthValidationError(field: .fullName, message: "Full name is required.")
        }
        guard trimmedName.count >= 2 else {
            return AuthValidationError(field: .fullName, message: "Enter your full name.")
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            return AuthValidationError(field: .email, message: "Email is required.")
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            return AuthValidationError(field: .email, message: "Enter a valid email address.")
        }

        guard password.count >= 8 else {
            return AuthValidationError(field: .password,
                                       message: "Password must be at least 8 characters.")
        }
        guard password.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            return AuthValidationError(field: .password,
                                       message: "Password needs at least one uppercase letter.")
        }
        guard password.rangeOfCharacter(from: .decimalDigits) != nil else {
            return AuthValidationError(field: .password,
                                       message: "Password needs at least one number.")
        }
        guard !confirmPassword.isEmpty else {
            return AuthValidationError(field: .confirmPassword,
                                       message: "Please confirm your password.")
        }
        guard confirmPassword == password else {
            return AuthValidationError(field: .confirmPassword,
                                       message: "Passwords do not match.")
        }

        return nil
    }

    // MARK: - Actions
    func signUp() {
        if let error = validate() {
            onValidationError?(error)
            return
        }

        state = .loading

        Task {
            do {
                let user = try await authService.signUp(
                    fullName: fullName.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                UserDefaultsHelper.saveUser(user)
                state = .success(user)

            } catch let error as AuthError {
                state = .failure(error.errorDescription ?? "Something went wrong.")
            } catch {
                state = .failure("Unexpected error. Please try again.")
            }
        }
    }

    private func clearValidationError() {
        DispatchQueue.main.async { [weak self] in
            self?.onValidationError?(nil)
        }
    }
}
