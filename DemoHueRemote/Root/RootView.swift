//
//  RootView.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 14/07/2020.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: Store<RootState, RootAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            switch viewStore.hueBridgeConfigStatus {
            case .unknown:
                Text("Checking for already configured Hue Bridges")
                    .onAppear {
                        viewStore.send(RootAction.checkForConfiguredBridges)
                    }
            case .configuring:
                ConfigHueBridgeView(
                    store: self.store.scope(
                        state: { $0.configHueBridgeState },
                        action: RootAction.config)
                )
            case .configured:
                HueView(
                    store: self.store.scope(
                        state: { $0.hueState },
                        action: RootAction.hue)
                )
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: RootState(),
                reducer: rootReducer,
                environment: RootEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    discoverHueAPI: MockDiscoverHueApi(),
                    objectPersistor: MockObjectPersistor()
                )
            )
        )
    }
}
