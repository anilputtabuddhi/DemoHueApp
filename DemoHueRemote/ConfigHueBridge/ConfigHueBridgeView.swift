//
//  ConfigHueBridgeView.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import SwiftUI
import ComposableArchitecture

struct ConfigHueBridgeView: View {
    let store: Store<ConfigHueBridgeState, ConfigHueBridgeAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView{
                VStack{
                    Spacer(minLength: 100)
                    switch viewStore.hueBridgeConfigStep {

                    case .notStarted:
                        HueBridgeImage(size: 200)
                        Button("Tap to Scan for Hue Bridges") {
                            viewStore.send(ConfigHueBridgeAction.scanBridgesTapped)
                        }

                    case .scanningForBridges:
                        Text("Scanning for bridges..")

                    case .scanFailed:
                        Text("Failed scanning for Bridges")
                        Divider()
                        Button("Try again"){
                            viewStore.send(ConfigHueBridgeAction.scanBridgesTapped)
                        }

                    case .list(let bridges, _) where bridges.count > 0:
                        BridgeSelection(
                            selection: viewStore.binding(
                                get: { _ in viewStore.hueBridgeConfigStep.hueBridgeSelection },
                                send: ConfigHueBridgeAction.selectBridge
                            ),
                            hueBridges: bridges,
                            connectAction: { viewStore.send(ConfigHueBridgeAction.authorise) }
                        )

                    case .list:
                        Text("No Philips Hue Bridges were found!!! " +
                                "Make sure you are on the same network as the Bridge.")
                        Divider()
                        Button("Try again"){
                            viewStore.send(ConfigHueBridgeAction.scanBridgesTapped)
                        }
                    case .authorizing(let hueBridge):
                        Text("Configuring Bridge: \(hueBridge.internalipaddress)")

                    case .authorized(let authBridge):
                        Text("Connection To Hue Bridge Successful.")
                        Divider()
                        HueBridgeDetailView(authBridge: authBridge)
                        Divider()
                        Text("You can remove the connection to the bridge from Settings Tab")
                            .font(.footnote)
                        Divider()
                        Button("OK") {
                            viewStore.send(ConfigHueBridgeAction.tappedOK)
                        }

                    case .authFailed:
                        Text("Failed to Authorize the selected Philips Hue Bridge. " +
                                "Please make sure the button on top of the bridge is clicked.")
                        Divider()
                        Button("Try again"){
                            viewStore.send(ConfigHueBridgeAction.scanBridgesTapped)
                        }
                    }
                }
                .font(.subheadline)
                .padding(.horizontal)
                .accentColor(.orange)
            }
        }

    }
}

struct BridgeSelection: View {
    @Binding var selection: Int
    var hueBridges: [HueBridge]
    var connectAction: () -> Void

    var body: some View {
        VStack {
            if hueBridges.count == 1 {
                Text("Found 1 Philips Hue Bridge. ")
                Divider()
                Text("\(hueBridges[0].internalipaddress)")
                Divider()
            } else {
                Text("Choose a Hue Bridge for authorisation. ")
                Divider()
                Picker(
                    selection: $selection,
                    label: EmptyView()
                ) {
                    ForEach(0 ..< hueBridges.count) {
                        Text("\(hueBridges[$0].internalipaddress)")
                    }
                }
                Divider()
            }
            HueBridgeImage(size: 100)
            Text("Make sure you click the button on top of your Philips Hue Bridge. " +
                    "Then tap on Connect below")
            Divider()
            Button("Connect") {
                connectAction()
            }
        }
    }
}

struct HueBridgeImage: View {
    let size: CGFloat
    var body: some View {
        Image("bridge_v2")
            .resizable()
            .frame(width: size, height: size, alignment: .center)
    }
}


struct ConfigHueBridgeView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigHueBridgeView(
            store: .init(
                initialState: ConfigHueBridgeState(),
                reducer: configHueBridgeReducer,
                environment: ConfigHueBridgeEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    discoverHueApi: MockDiscoverHueApi()
                )
            )
        )
    }
}
