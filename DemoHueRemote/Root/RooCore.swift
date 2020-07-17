//
//  RooCore.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 14/07/2020.
//

import Foundation
import ComposableArchitecture
import Combine

enum HueBridgeConfigStatus: Equatable {
    case unknown
    case configuring(ConfigHueBridgeState)
    case configured(HueState)
}
struct RootState: Equatable {
    var hueBridgeConfigStatus: HueBridgeConfigStatus = .unknown
}

enum RootAction: Equatable {
    case config(ConfigHueBridgeAction)
    case hue(HueAction)
    case checkForConfiguredBridges
}

struct RootEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var discoverHueAPI: DiscoverHueAPI
    var objectPersistor: ObjectPersistor

    static let authBridgeKey = "authorisedBridge"

    static let live = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        discoverHueAPI: LiveDiscoverHueApi(),
        objectPersistor: UserDefaultObjectPersistor()
    )
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
    hueReducer.pullback(
        state: \.hueState,
        action: /RootAction.hue,
        environment: {
            let authorisedHueBridge: AuthorisedHueBridge? =
                $0.objectPersistor.object(forKey: RootEnvironment.authBridgeKey)
            return HueEnvironment(
                mainQueue: $0.mainQueue,
                api: HueAPI(authorisedHueBridge: authorisedHueBridge),
                objectPersistor: $0.objectPersistor
            )
        }
    ),
    configHueBridgeReducer.pullback(
        state: \.configHueBridgeState,
        action: /RootAction.config,
        environment: {
            ConfigHueBridgeEnvironment(mainQueue: $0.mainQueue,
                                       discoverHueApi: $0.discoverHueAPI)
        }
    ),
    Reducer { state, action, environment in
        switch action {
        case .config(.authorizeBridgesResponse(.success(let authorisedBridge))):
            environment.objectPersistor.set(authorisedBridge, forKey: RootEnvironment.authBridgeKey)
            return .none
        case .config(.tappedOK):
            state.hueBridgeConfigStatus = .configured(HueState())
            return .none
        case .config:
            return .none
        case .hue(.settingsTab(.removeHueBridgeTapped)):
            environment.objectPersistor.set(AuthorisedHueBridge?.none, forKey: RootEnvironment.authBridgeKey)
            state.hueBridgeConfigStatus = .unknown
            return .none
        case .hue:
            return .none
        case .checkForConfiguredBridges:
            let authorisedHueBridge: AuthorisedHueBridge? =
                environment.objectPersistor.object(forKey: RootEnvironment.authBridgeKey)
            if authorisedHueBridge == nil {
                state.hueBridgeConfigStatus = .configuring(ConfigHueBridgeState())
            } else {
                state.hueBridgeConfigStatus = .configured(HueState())
            }
            return .none
        }
    }
)

extension RootState {
    var hueState: HueState {
        get {
            if case let .configured(hStatus) = self.hueBridgeConfigStatus {
                return hStatus
            } else {
                return HueState()
            }
        }

        set {
            if case .configured = self.hueBridgeConfigStatus {
                self.hueBridgeConfigStatus = .configured(newValue)
            }
        }
    }

    var configHueBridgeState: ConfigHueBridgeState {
        get {
            if case let .configuring(cState) = self.hueBridgeConfigStatus {
                return cState
            } else {
                return ConfigHueBridgeState()
            }
        }

        set {
            if case .configuring = self.hueBridgeConfigStatus {
                self.hueBridgeConfigStatus = .configuring(newValue)
            }
        }
    }
}
