//
//  LightListView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import SwiftUI
import ComposableArchitecture

struct LightListView: View {
    let store: Store<LightListState, LightListAction>

    var body: some View {
        VStack {
            ForEachStore(
                self.store.scope(
                    state: { $0 },
                    action: LightListAction.light(id:action:)
                ),
                content: { itemStore in
                    VStack {
                        LightView.init(store: itemStore)
                        Divider()
                    }
                }
            )
        }
        .listStyle(PlainListStyle())
    }
}

struct LightListView_Previews: PreviewProvider {
    static var previews: some View {
        LightListView(
            store: .init(
                initialState: IdentifiedArray(Light.testLights),
                reducer: lightListReducer,
                environment: LightListEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    api: MockHueAPI()
                )
            )
        )
    }
}
