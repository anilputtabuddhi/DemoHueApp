//
//  GroupListView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct GroupListView: View {
    let store: Store<GroupListState, GroupListAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEachStore(
                    self.store.scope(
                        state: { $0.groups },
                        action: GroupListAction.group(id:action:)
                    ),
                    content: { itemStore in
                        WithViewStore(itemStore) { viewItemStore in

                            NavigationLink(
                                destination: GroupDetailView(store: itemStore)
                                    .padding(.horizontal)
                            ) {
                                GroupView.init(store: itemStore)
                            }
                        }
                    }
                )
            }
            .listStyle(PlainListStyle())
        }
    }

}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView(
            store: .init(
                initialState: GroupListState(groups: IdentifiedArray(Group.testGroups)),
                reducer: groupListReducer,
                environment: GroupListEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    api: MockHueAPI()
                )
            )
        )
    }
}
