//
//  GroupDetailView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import SwiftUI
import ComposableArchitecture

struct GroupDetailView: View {
    let store: Store<GroupState, GroupAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                VStack(alignment: .leading){
                    Text(viewStore.status)
                    if viewStore.canControl {
                        BrightnessControl(value: viewStore.binding(
                                get: { Float($0.brightness) },
                                send: GroupAction.setBrightness
                            )
                        )
                    }
                    Divider()
                    Spacer(minLength: 20)
                    LightListView(
                        store: self.store.scope(
                            state: { $0.lightsList },
                            action: GroupAction.lights
                        )
                    )
                    .padding(.horizontal)
                }
            }
            .navigationTitle(viewStore.name)
            .navigationBarItems(
                trailing: Toggle(
                    isOn: viewStore.binding(
                        get: { $0.isAnyLightOn },
                        send: GroupAction.toggleOnStatus
                    ),
                    label: { EmptyView() }
                )
                .disabled(!viewStore.isAnyLightReachable)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            )
        }
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailView(store: .init(
            initialState: Group.testGroups[0],
            reducer: groupReducer,
            environment: GroupEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                api: MockHueAPI()
            )
          )
        )
    }
}
