//
//  MockHueAPI.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 13/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

struct MockHueAPI: HueAPIProtocol {
    var isAuthorised: Bool = true

    func toggleOnFor(group: Group, value: Bool) -> Effect<Bool, Never> {
        Just(true)
            .eraseToEffect()
    }

    func setBrightnessFor(group: Group, value: Int) -> Effect<Bool, Never> {
        Just(true)
            .eraseToEffect()
    }

    func toggleOnFor(light: Light, value: Bool) -> Effect<Bool, Never> {
        Just(true)
            .eraseToEffect()
    }

    func setBrightnessFor(light: Light, value: Int) -> Effect<Bool, Never> {
        Just(true)
            .eraseToEffect()
    }

    func setColorTemperatureFor(light: Light, value: Int) -> Effect<Bool, Never> {
        Just(true)
            .eraseToEffect()
    }

    func groups() -> Effect<[Group], GroupDataFetchError> {
        Just(Group.testGroups)
            .mapError { _ in GroupDataFetchError.unknown }
            .eraseToEffect()
    }

    func lights() -> Effect<[Light], LightsDataFetchError> {
        Just(Light.testLights)
            .mapError { _ in LightsDataFetchError.unknown }
            .eraseToEffect()
    }

}
