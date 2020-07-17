//
//  ContentView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct HueView: View {
    let store: Store<HueState, HueAction>

    var body: some View {
        TabView {
            GroupsTabView(
                store: self.store.scope(
                    state: { $0.groupsTab },
                    action: HueAction.groupsTab
                )
            )
            .tabItem {
                Image(systemName: "house")
                Text("Groups")
            }
            LightsTabView(
                store: self.store.scope(
                    state: { $0.lightsTab },
                    action: HueAction.lightsTab
                )
            )
            .tabItem {
                Image(systemName: "lightbulb")
                Text("Lights")
            }
            SettingsTabView(
                store: self.store.scope(
                    state: { $0.settingsTab },
                    action: HueAction.settingsTab
                )
            )
            .tabItem {
                Image(systemName: "gearshape.2")
                Text("Settings")
            }
        }
        .accentColor(.orange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HueView(
            store: .init(
                initialState: HueState(),
                reducer: hueReducer,
                environment: HueEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    api: MockHueAPI(),
                    objectPersistor: MockObjectPersistor()
                )
            )
        )
    }
}
