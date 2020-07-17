//
//  ConfigHueBridgeCore.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation
import ComposableArchitecture
import Combine

enum HueBrigeConfigStep: Equatable {
    case notStarted
    case scanningForBridges
    case scanFailed
    case list(hueBridges: [HueBridge], selection: Int)
    case authorizing(hueBridge: HueBridge)
    case authFailed
    case authorized(AuthorisedHueBridge)
}

struct ConfigHueBridgeState: Equatable {
    var hueBridgeConfigStep: HueBrigeConfigStep = .notStarted
}

enum ConfigHueBridgeAction: Equatable {
    case scanBridgesTapped
    case scanBridgesResponse(Result<[HueBridge], ScanBridgesError>)
    case selectBridge(Int)
    case authorise
    case authorizeBridgesResponse(Result<AuthorisedHueBridge, AuthBridgeError>)
    case tappedOK
}

struct ConfigHueBridgeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var discoverHueApi: DiscoverHueAPI
}

enum ScanBridgesError: Error, Equatable {
    case unknown
}

enum AuthBridgeError: Error, Equatable {
    case unknown
    case linkButtonNotTapped
}

let configHueBridgeReducer = Reducer<ConfigHueBridgeState, ConfigHueBridgeAction, ConfigHueBridgeEnvironment> {
    state, action, environment in

    struct ScanBridgesRequestId: Hashable {}
    struct AuthorizeBridgesRequestId: Hashable {}

    switch action {

    case .scanBridgesTapped:
        state.hueBridgeConfigStep = .scanningForBridges
        return environment.discoverHueApi.scanForHueBridges()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(ConfigHueBridgeAction.scanBridgesResponse)
            .cancellable(id: ScanBridgesRequestId())

    case .scanBridgesResponse(.success(let bridges)):
        state.hueBridgeConfigStep = .list(hueBridges: bridges, selection: bridges.startIndex)
        return .none

    case .scanBridgesResponse(.failure):
        state.hueBridgeConfigStep = .scanFailed
        return .none

    case .selectBridge(let selectIndex):
        state.hueBridgeConfigStep.hueBridgeSelection = selectIndex
        return .none

    case .authorise:
        if case let .list(bridges, selectionIndex) = state.hueBridgeConfigStep {
            state.hueBridgeConfigStep = .authorizing(hueBridge: bridges[selectionIndex])
            return environment.discoverHueApi.authorize(hueBridge: bridges[selectionIndex])
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(ConfigHueBridgeAction.authorizeBridgesResponse)
                .cancellable(id: AuthorizeBridgesRequestId())
        } else {
            return .none
        }

    case .authorizeBridgesResponse(.success(let authorisedBridge)):
        state.hueBridgeConfigStep = .authorized(authorisedBridge)
        return .none

    case .authorizeBridgesResponse(.failure):
        state.hueBridgeConfigStep = .authFailed
        return .none

    case .tappedOK:
        return .none
    }
}

extension HueBrigeConfigStep {
    var hueBridgeSelection: Int {
        get {
            if case let .list(_, selection) = self {
                return selection
            } else {
                return -1
            }
        }

        set {
            if case let .list(bridges, _) = self {
                self = .list(hueBridges: bridges, selection: newValue)
            }
        }
    }
}
