//
//  SettingsTabCore.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation
import ComposableArchitecture
import Combine

enum SettingStatus: Equatable {
    case showing(AuthorisedHueBridge)
    case none
}
struct SettingsTabState: Equatable {
    var settingStatus: SettingStatus = .none
}

enum SettingsTabAction: Equatable {
    case fetchSettings
    case removeHueBridgeTapped
}

struct SettingsTabEnvironment {
    var objectPersistor: ObjectPersistor
}

let settingsTabReducer = Reducer<SettingsTabState, SettingsTabAction, SettingsTabEnvironment> {
    state, action, environment in
    switch action {
    case .fetchSettings:
        if let authorisedHueBridge: AuthorisedHueBridge =
            environment.objectPersistor.object(forKey: RootEnvironment.authBridgeKey) {
            state.settingStatus = .showing(authorisedHueBridge)
        }
        return .none
    case .removeHueBridgeTapped:
        state.settingStatus = .none
        return .none
    }
}
