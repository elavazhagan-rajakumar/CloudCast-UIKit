//
//  LoginViewModel.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//
import Foundation

final class LoginViewModel {

    // MARK: - Bindings (ViewController subscribes to these)
    var onStateChange: ((AuthViewState) -> Void)?
    var onValidationError: ((AuthValidationError?) -> Void)?

    // MARK: - Private inputs
    private var email: String = ""
    private var password: String = ""

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
    // ViewController passes nothing → gets MockAuthService by default
    // Unit test passes MockAuthService with custom behavior
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    // MARK: - Input handlers (called on every keystroke)
    func emailChanged(_ text: String) {
        email = text
        clearValidationError()
    }

    func passwordChanged(_ text: String) {
        password = text
        clearValidationError()
    }

    // MARK: - Validation
    private func validate() -> AuthValidationError? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty else {
            return AuthValidationError(field: .email, message: "Email cannot be empty.")
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            return AuthValidationError(field: .email, message: "Enter a valid email address.")
        }
        guard !password.isEmpty else {
            return AuthValidationError(field: .password, message: "Password cannot be empty.")
        }
        guard password.count >= 6 else {
            return AuthValidationError(field: .password, message: "Password must be at least 6 characters.")
        }

        return nil
    }

    // MARK: - Actions
    func login() {
        if let error = validate() {
            onValidationError?(error)
            return
        }

        state = .loading

        Task {
            do {
                let user = try await authService.login(
                    email: email,
                    password: password
                )
                // Save session
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
