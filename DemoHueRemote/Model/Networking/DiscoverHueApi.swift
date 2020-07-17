//
//  DiscoverHueApi.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

protocol DiscoverHueAPI {
    func scanForHueBridges() -> Effect<[HueBridge], ScanBridgesError>
    func authorize(hueBridge: HueBridge) -> Effect<AuthorisedHueBridge, AuthBridgeError>
}

struct LiveDiscoverHueApi: DiscoverHueAPI{

    struct AuthError: Codable {
        let error: AuthErrorDescription
    }

    struct AuthErrorDescription: Codable {
        let type: Int
        let address: String
        let description: String
    }

    struct AuthSuccess: Codable {
        let success: AuthSuccessInfo
    }

    struct AuthSuccessInfo: Codable {
        let username: String
    }
    
    let network = Network()
    let url = URL(string: "https://discovery.meethue.com/")!

    func scanForHueBridges() -> Effect<[HueBridge], ScanBridgesError> {
        let request = URLRequest(url: url)
        return network.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
            .mapError{ _  in
                ScanBridgesError.unknown
            }
            .eraseToEffect()
    }

    func authorize(hueBridge: HueBridge) -> Effect<AuthorisedHueBridge, AuthBridgeError> {
        
        let parameters = "{\"devicetype\":\"my_hue_app#iphone peter\"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "http://\(hueBridge.internalipaddress)/api")!)
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData


        let authPublisher: Effect<Data, Error>
            = network.runWithoutDecoding(request)

        return authPublisher
            .tryMap{ data  in
                let decoder = JSONDecoder()
                if let successInfo = try? decoder.decode([AuthSuccess].self, from: data).first {
                    return AuthorisedHueBridge(hueBridge: hueBridge, user: successInfo.success.username)
                } else if let errorInfo = try? decoder.decode([AuthError].self, from: data).first,
                          errorInfo.error.description == "link button not pressed" {
                    throw AuthBridgeError.linkButtonNotTapped
                }
                throw AuthBridgeError.unknown
            }
            .eraseToAnyPublisher()
            .mapError{ error  in
                return AuthBridgeError.unknown
            }
            .eraseToEffect()
    }
}
