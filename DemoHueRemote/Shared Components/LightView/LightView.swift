//
//  LightView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 12/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct LightView: View {
    let store: Store<LightState, LightAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TitledToggleView(
                    isOn: viewStore.binding(get: { $0.isOn },
                                            send: LightAction.toggleOnStatus),
                    isEnabled: viewStore.reachable,
                    imageName: viewStore.imageName,
                    title: viewStore.name,
                    subTitle: viewStore.status
                )
                if viewStore.isOn && viewStore.reachable {
                    HStack {
                        Image(systemName: "sun.max")
                        Slider(value: viewStore.binding(get: { Float($0.brightness) },
                                                        send: LightAction.setBrightness),
                               in: 0...255, step: 1.0)
                    }
                }
            }
        }
    }
}

struct LightView_Previews: PreviewProvider {
    static var previews: some View {
        LightView(store: .init(
            initialState: Light.testLights[0],
            reducer: lightReducer,
            environment: LightEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                api: MockHueAPI()
            )
          )
        )
    }
}
