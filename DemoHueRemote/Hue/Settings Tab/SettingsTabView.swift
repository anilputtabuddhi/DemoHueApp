//
//  SettingsTabView.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import SwiftUI
import ComposableArchitecture

struct SettingsTabView: View {
    let store: Store<SettingsTabState, SettingsTabAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            switch viewStore.settingStatus {
            case .none:
                Text("Fetching Settings...")
                    .onAppear {
                        viewStore.send(SettingsTabAction.fetchSettings)
                    }
            case .showing(let authBridge):
                VStack {
                    Text("Currently connected to Hue Bridge:")
                    Divider()
                    HueBridgeDetailView(authBridge: authBridge)
                    Divider()
                    Button("Remove Hue Bridge") {
                        viewStore.send(SettingsTabAction.removeHueBridgeTapped)
                    }
                }
            }
        }
    }
}

//struct SettingsTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsTabView()
//    }
//}
