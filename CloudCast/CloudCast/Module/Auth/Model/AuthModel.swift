//
//  AuthModel.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import Foundation

// MARK: - User model stored after login/signup
struct AuthUser {
    let id: String
    let fullName: String
    let email: String
}

// MARK: - View states (shared between Login and SignUp ViewModels)
enum AuthViewState {
    case idle
    case loading
    case success(AuthUser)
    case failure(String)
}

// MARK: - Validation error carries which field failed
enum AuthField {
    case fullName
    case email
    case password
    case confirmPassword
}

struct AuthValidationError {
    let field: AuthField
    let message: String
}
