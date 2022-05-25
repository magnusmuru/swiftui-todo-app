//
//  LoginResponseEntity.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

struct LoginResponseEntity: Codable {
    var token: String
    var refreshToken: String
    var firstName: String
    var lastName: String
}
