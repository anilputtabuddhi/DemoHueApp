//
//  GroupsTabCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import Foundation
import ComposableArchitecture

struct GroupsTabState: Equatable {

    var groupsDataStatus: DataStatus<[Group]> = .notStarted

    var groupsList: GroupListState {
        get {
            if case .loaded(let groups) = groupsDataStatus {
                return GroupListState(groups: IdentifiedArrayOf(groups))
            } else {
                return GroupListState()
            }
        }

        set {
            if case .loaded = groupsDataStatus {
                self.groupsDataStatus = .loaded(data: newValue.groups.elements)
            }
        }
    }
}

enum GroupDataFetchError: Error, Equatable {
    case unknown
}
enum GroupsTabAction: Equatable {
    case onAppear
    case groupsResponse(Result<[Group], GroupDataFetchError>)
    case groupsList(GroupListAction)
    case retry
    case refresh
    case timerTicked
}

struct GroupsTabEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let groupsTabReducer = Reducer<GroupsTabState, GroupsTabAction, GroupsTabEnvironment>.combine(
    groupListReducer.pullback(
        state: \.groupsList,
        action: /GroupsTabAction.groupsList,
        environment: { 
            GroupListEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    ),
    Reducer { state, action, environment in
        struct GroupsRequestId: Hashable {}
        struct TimerId: Hashable {}

        guard environment.api.isAuthorised else {
            return .none
        }

        switch action {
        case .onAppear, .retry, .refresh, .timerTicked:
            state.groupsDataStatus = .loading
            return environment.api.groups()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(GroupsTabAction.groupsResponse)
                .cancellable(id: GroupsRequestId())
        case .groupsResponse(.success(let groups)):
            let sortedGroups = groups.sorted()
            state.groupsDataStatus = .loaded(data: sortedGroups)
            return .none
        case .groupsResponse(.failure):
            state.groupsDataStatus = .failed
            return .none
        case .groupsList(_):
            return .none
        }
    }
)
