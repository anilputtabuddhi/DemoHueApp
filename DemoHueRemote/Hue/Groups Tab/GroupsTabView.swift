//
//  GroupsTabView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct GroupsTabView: View {
    let store: Store<GroupsTabState, GroupsTabAction>

    var body: some View {
            WithViewStore(self.store) { viewStore in
                switch viewStore.groupsDataStatus {
                case .failed:
                    VStack{
                        Text("Failed to fetch group data")
                        Button("Retry Fetching"){
                            viewStore.send(GroupsTabAction.retry)
                        }
                    }
                    .navigationBarItems(trailing: EmptyView())

                case .loading:
                    ProgressView() {
                        Text("Fetching data..")
                    }
                    .navigationBarItems(trailing: EmptyView())
                case .loaded:
                    NavigationView {
                        GroupListView(
                            store: self.store.scope(
                                state: { $0.groupsList },
                                action: GroupsTabAction.groupsList
                            )
                        )
                        .navigationTitle("Groups")
                        .navigationBarItems(
                            trailing: Button(action: {
                                viewStore.send(GroupsTabAction.refresh)
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        )
                    }
                case .notStarted:
                    EmptyView()
                        .onAppear {
                            viewStore.send(.onAppear)
                        }
                        .navigationBarItems(trailing: EmptyView())
                }
            }
    }
}


struct GroupsTabView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsTabView(
            store: .init(
                initialState: GroupsTabState(
                    groupsDataStatus: .loaded(data: Group.testGroups)
                ),
                reducer: groupsTabReducer,
                environment: GroupsTabEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    api: MockHueAPI())
            )
        )
    }
}
