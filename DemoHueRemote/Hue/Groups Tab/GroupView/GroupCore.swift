//
//  GroupCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import Foundation
import ComposableArchitecture

typealias GroupState = Group

extension Group {
    var lightsList: LightListState {
        get {
            IdentifiedArrayOf(lights)
        }
        set {
            self.lights = newValue.elements
        }
    }
}

enum GroupAction: Equatable {
    case setBrightnessResponse(Result<Bool, Never>)
    case toggleResponse(Result<Bool, Never>)
    case setBrightness(value: Float)
    case toggleOnStatus(value: Bool)
    case lights(LightListAction)
}

struct GroupEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let groupReducer = Reducer<GroupState, GroupAction, GroupEnvironment>.combine(
    lightListReducer.pullback(
        state: \.lightsList,
        action: /GroupAction.lights,
        environment: {
            LightListEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    ),
    Reducer { state, action, environment in
        struct ToggleRequestId: Hashable {}
        struct BrightnessRequestId: Hashable {}
        
        switch action {
        
        case .setBrightness(let value):
            state.brightness = Int(value)
            return environment.api.setBrightnessFor(group: state, value: state.brightness)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(GroupAction.setBrightnessResponse)
                .cancellable(id: BrightnessRequestId())
            
        case .toggleOnStatus(let value):
            state.isAnyLightOn = value
            return environment.api.toggleOnFor(group: state, value: state.isAnyLightOn)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(GroupAction.toggleResponse)
                .cancellable(id: ToggleRequestId())
            
        case .toggleResponse:
            return .none
            
        case .setBrightnessResponse:
            return .none
            
        case .lights:
            return .none
        }
    }
)

