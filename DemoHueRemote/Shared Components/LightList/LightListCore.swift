//
//  LightListCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import Foundation
import ComposableArchitecture

typealias LightListState = IdentifiedArrayOf<Light>

enum LightListAction: Equatable {
    case light(id: String, action: LightAction)
}

struct LightListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let lightListReducer = Reducer<LightListState, LightListAction, LightListEnvironment>.combine(
    Reducer { state, action, environment in
        return .none
    },
    lightReducer.forEach(
        state: \.self,
        action: /LightListAction.light(id:action:),
        environment: {
            LightEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    )
)
