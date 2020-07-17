//
//  MockDiscoverHueApi.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

struct MockDiscoverHueApi: DiscoverHueAPI {
    func scanForHueBridges() -> Effect<[HueBridge], ScanBridgesError> {
        Just(HueBridge.testBridges)
            .mapError { _ in ScanBridgesError.unknown }
            .eraseToEffect()
    }

    func authorize(hueBridge: HueBridge) -> Effect<AuthorisedHueBridge, AuthBridgeError> {
        Just(AuthorisedHueBridge(hueBridge: hueBridge, user: "123"))
            .mapError { _ in AuthBridgeError.unknown }
            .eraseToEffect()
    }
}
