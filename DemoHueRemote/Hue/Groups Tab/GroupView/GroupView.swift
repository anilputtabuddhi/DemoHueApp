//
//  GroupView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct GroupView: View {
    let store: Store<GroupState, GroupAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TitledToggleView(
                    isOn: viewStore.binding(
                        get: { $0.isAnyLightOn },
                        send: GroupAction.toggleOnStatus
                    ),
                    isEnabled: viewStore.isAnyLightReachable,
                    imageName: viewStore.imageName,
                    title: viewStore.name,
                    subTitle: viewStore.status
                )
                if viewStore.canControl {
                    BrightnessControl(value: viewStore.binding(
                            get: { Float($0.brightness) },
                            send: GroupAction.setBrightness
                        )
                    )
                }
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView(
            store: .init(
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
