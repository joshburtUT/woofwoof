//
//  EditProfileViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .fullname: return "Name"
        case .username: return "Username"
        case .bio: return "Bio"
        }
    }
}

class EditProfileViewModel {
    
    // MARK: - Properties
    private let user: UserModel
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        case .bio: return user.bio
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    var shouldHideTextView: Bool {
        return option != .bio
    }
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    
    // MARK: - Lifecycle
    init(user: UserModel, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
