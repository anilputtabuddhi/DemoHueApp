//
//  LightsTabView.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 13/07/2020.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct LightsTabView: View {
    let store: Store<LightsTabState, LightsTabAction>

    var body: some View {
            WithViewStore(self.store) { viewStore in
                switch viewStore.lightsDataStatus {
                case .failed:
                    VStack{
                        Text("Failed to fetch lights data")
                        Button("Retry Fetching"){
                            viewStore.send(LightsTabAction.retry)
                        }
                    }
                    .navigationBarItems(trailing: EmptyView())

                case .loading:
                    ProgressView() {
                        Text("Fetching data..")
                    }
                    .navigationBarItems(trailing: EmptyView())
                case .loaded:
                    NavigationView{
                        ScrollView{
                            LightListView(
                                store: self.store.scope(
                                    state: { $0.lightsList },
                                    action: LightsTabAction.lightsList
                                )
                            )
                            .padding(.horizontal)
                        }
                        .navigationTitle("Lights")
                        .navigationBarItems(
                            trailing: Button(action: {
                                viewStore.send(LightsTabAction.refresh)
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

struct LightsTabView_Previews: PreviewProvider {
    static var previews: some View {
        LightsTabView(
            store: .init(
                initialState: LightsTabState(),
                reducer: lightsTabReducer,
                environment: LightsTabEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    api: MockHueAPI())
            )
        )
    }
}

