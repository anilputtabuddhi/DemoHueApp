//
//  GroupListCore.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import Foundation
import ComposableArchitecture

struct GroupListState: Equatable {
    var groups: IdentifiedArrayOf<Group> = []
    var selection: String?
}
enum GroupListAction: Equatable {
    case group(id: String, action: GroupAction)
    case selectGroup(id: String?)
}

struct GroupListEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var api: HueAPIProtocol
}

let groupListReducer = Reducer<GroupListState, GroupListAction, GroupListEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {
        case .group(id: let id, action: let action):
            return .none
        case .selectGroup(let id):
            state.selection = id
            return .none
        }
    },
    groupReducer.forEach(
        state: \.groups,
        action: /GroupListAction.group(id:action:),
        environment: {
            GroupEnvironment(
                mainQueue: $0.mainQueue,
                api: $0.api
            )
        }
    )
)
