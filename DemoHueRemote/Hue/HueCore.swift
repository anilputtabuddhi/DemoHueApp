//  HueCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import Foundation
import ComposableArchitecture
import Combine

struct HueState: Equatable {
    var dataStatus: DataStatus<[Group]> = .notStarted
    var settingsTab = SettingsTabState()
}

enum HueAction: Equatable {
    case groupsTab(GroupsTabAction)
    case lightsTab(LightsTabAction)
    case settingsTab(SettingsTabAction)
}

struct HueEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
    var objectPersistor: ObjectPersistor
}

let hueReducer = Reducer<HueState, HueAction, HueEnvironment>.combine(
    lightsTabReducer.pullback(
        state: \.lightsTab,
        action: /HueAction.lightsTab,
        environment: {
            LightsTabEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    ),
    groupsTabReducer.pullback(
        state: \.groupsTab,
        action: /HueAction.groupsTab,
        environment: {
            GroupsTabEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    ),
    settingsTabReducer.pullback(
        state: \.settingsTab,
        action: /HueAction.settingsTab,
        environment: { 
            SettingsTabEnvironment(objectPersistor: $0.objectPersistor)
        }
    ),
    Reducer { state, action, _ in
        switch action {
        case .groupsTab:
            return .none
        case .lightsTab:
            return .none
        case .settingsTab:
            return .none
        }
    }
)

extension DataStatus where T == [Group] {
    func toLightsDataStatus() -> DataStatus<[Light]> {
        switch self {
        case .notStarted:
            return .notStarted
        case .loading:
            return .loading
        case .loaded(let groups):
        return .loaded(data: groups.flatMap(\.lights))
        case .failed:
            return .failed
        }
    }

    func withNewLights(_ lights: [Light]) -> DataStatus<[Group]> {
        switch self {
        case .notStarted:
            return .notStarted
        case .loading:
            return .loading
        case .loaded(let groups):
            let newGroups = groups.map { group -> Group in
                let filteredLights = lights.filter { light in
                    group.lights.map(\.id).contains(light.id)
                }
                return group.newGroupWith(filteredLights)
            }

        return .loaded(data: newGroups)
        case .failed:
            return .failed
        }
    }
}

extension HueState {
    var groupsTab: GroupsTabState {
        get {
            GroupsTabState(groupsDataStatus: dataStatus)
        }
        set {
            dataStatus = newValue.groupsDataStatus
        }
    }
    var lightsTab: LightsTabState {
        get {
            LightsTabState(lightsDataStatus: dataStatus.toLightsDataStatus())
        }
        set {
            if case let .loaded(lights) = newValue.lightsDataStatus {
                dataStatus = dataStatus.withNewLights(lights)
            }
        }
    }
}
