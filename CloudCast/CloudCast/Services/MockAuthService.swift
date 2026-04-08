//
//  MockAuthService.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import Foundation

// MARK: - Protocol
// Both MockAuthService and (future) real AuthService conform to this.
// ViewModels depend on the protocol, never the concrete type.
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthUser
    func signUp(fullName: String, email: String, password: String) async throws -> AuthUser
}

// MARK: - Mock error cases
enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Incorrect email or password."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .networkError(let msg):
            return "Network error: \(msg)"
        }
    }
}

// MARK: - Mock implementation
// Simulates a real backend with a fake in-memory user store.
// When you have a real API later, just swap this class out —
// ViewModels don't change at all because they use the protocol.
final class MockAuthService: AuthServiceProtocol {

    // In-memory "database" of registered users
    // Key = email (lowercased), Value = (password, AuthUser)
    private var registeredUsers: [String: (password: String, user: AuthUser)] = [
        // Pre-seeded test account so login works immediately
        "test@cloudcast.com": (
            password: "Test@123",
            user: AuthUser(
                id: UUID().uuidString,
                fullName: "Test User",
                email: "test@cloudcast.com"
            )
        )
    ]

    func login(email: String, password: String) async throws -> AuthUser {
        // Simulate network delay (0.8 seconds)
        try await Task.sleep(nanoseconds: 800_000_000)

        let key = email.lowercased().trimmingCharacters(in: .whitespaces)

        guard let record = registeredUsers[key] else {
            throw AuthError.invalidCredentials
        }
        guard record.password == password else {
            throw AuthError.invalidCredentials
        }

        return record.user
    }

    func signUp(fullName: String, email: String, password: String) async throws -> AuthUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let key = email.lowercased().trimmingCharacters(in: .whitespaces)

        // Check duplicate
        if registeredUsers[key] != nil {
            throw AuthError.emailAlreadyExists
        }

        // Create and store new user
        let newUser = AuthUser(
            id: UUID().uuidString,
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            email: email.lowercased().trimmingCharacters(in: .whitespaces)
        )

        registeredUsers[key] = (password: password, user: newUser)
        return newUser
    }
}
