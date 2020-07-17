//
//  LightsTabCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 13/07/2020.
//

import Foundation
import ComposableArchitecture

struct LightsTabState: Equatable {

    var lightsDataStatus: DataStatus<[Light]> = .notStarted

    var lightsList: IdentifiedArrayOf<Light> {
        get {
            switch lightsDataStatus {
            case .loaded(let lights):
                return IdentifiedArrayOf(lights)
            default:
                return []
            }
        }

        set {
            self.lightsDataStatus = .loaded(data: newValue.elements)
        }
    }
}

enum LightsDataFetchError: Error, Equatable {
    case unknown
}
enum LightsTabAction: Equatable {
    case onAppear
    case lightsResponse(Result<[Light], LightsDataFetchError>)
    case lightsList(LightListAction)
    case retry
    case refresh
    case timerTicked
}

struct LightsTabEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let lightsTabReducer = Reducer<LightsTabState, LightsTabAction, LightsTabEnvironment>.combine(
    lightListReducer.pullback(
        state: \.lightsList,
        action: /LightsTabAction.lightsList,
        environment: {
            LightListEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    ),
    Reducer { state, action, environment in
        struct LIghtsRequestId: Hashable {}
        struct TimerId: Hashable {}

        guard environment.api.isAuthorised else {
            return .none
        }
        
        switch action {
        case .onAppear, .retry, .refresh, .timerTicked:
            state.lightsDataStatus = .loading
            return environment.api.lights()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(LightsTabAction.lightsResponse)
                .cancellable(id: LIghtsRequestId())
        case .lightsResponse(.success(let lights)):
            let sortedLights = lights.sorted()
            state.lightsDataStatus = .loaded(data: sortedLights)
            return .none
        case .lightsResponse(.failure):
            state.lightsDataStatus = .failed
            return .none
        case .lightsList(_):
            return .none
        }
    }
)
