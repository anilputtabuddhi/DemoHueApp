//
//  AuthorizedHueBridge.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation

struct AuthorisedHueBridge: Equatable, Codable {
    let hueBridge: HueBridge
    let user: String
}
