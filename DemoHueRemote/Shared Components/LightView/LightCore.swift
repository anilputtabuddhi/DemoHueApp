//
//  LightCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import Foundation
import ComposableArchitecture

typealias LightState = Light

enum LightAction: Equatable {
    case setBrightnessResponse(Result<Bool, Never>)
    case setColorTemperatureResponse(Result<Bool, Never>)
    case toggleResponse(Result<Bool, Never>)
    case setBrightness(value: Float)
    case setColorTemperature(value: Float)
    case toggleOnStatus(value: Bool)
}

struct LightEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let lightReducer = Reducer<LightState, LightAction, LightEnvironment> {
    state, action, environment in
    struct ToggleOnRequestId: Hashable {}
    struct SetBrightnessRequestId: Hashable {}
    struct SetColorTemperatureRequestId: Hashable {}

    switch action {

    case .setBrightness(let value):
        state.brightness = Int(value)
        return environment.api.setBrightnessFor(light: state, value: state.brightness)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(LightAction.setBrightnessResponse)
            .cancellable(id: SetBrightnessRequestId())

    case .toggleOnStatus(let value):
        state.isOn = value
        return environment.api.toggleOnFor(light: state, value: state.isOn)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(LightAction.toggleResponse)
            .cancellable(id: ToggleOnRequestId())

    case .toggleResponse:
        return .none

    case .setBrightnessResponse:
        return .none

    case .setColorTemperatureResponse:
        return .none
        
    case .setColorTemperature(value: let value):
        state.colorTemperature = Int(value)
        return environment.api.setColorTemperatureFor(light: state, value: state.brightness)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(LightAction.setBrightnessResponse)
            .cancellable(id: SetColorTemperatureRequestId())
    }
}
