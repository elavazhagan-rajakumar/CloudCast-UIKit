//
//  UserDefaultsHelper.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import Foundation

enum UserDefaultsHelper {

    private enum Keys {
        static let userName  = "cloudcast_user_name"
        static let userEmail = "cloudcast_user_email"
        static let userId    = "cloudcast_user_id"
        static let isLoggedIn = "cloudscast_is_logged_in"
    }

    static func saveUser(_ user: AuthUser) {
        let defaults = UserDefaults.standard
        defaults.set(user.id,       forKey: Keys.userId)
        defaults.set(user.fullName, forKey: Keys.userName)
        defaults.set(user.email,    forKey: Keys.userEmail)
        defaults.set(true,          forKey: Keys.isLoggedIn)
    }

    static func getSavedUser() -> AuthUser? {
        let defaults = UserDefaults.standard
        guard
            let id    = defaults.string(forKey: Keys.userId),
            let name  = defaults.string(forKey: Keys.userName),
            let email = defaults.string(forKey: Keys.userEmail)
        else { return nil }
        return AuthUser(id: id, fullName: name, email: email)
    }

    static func isLoggedIn() -> Bool {
        UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
    }

    static func clearUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.userName)
        defaults.removeObject(forKey: Keys.userEmail)
        defaults.set(false, forKey: Keys.isLoggedIn)
    }
}
