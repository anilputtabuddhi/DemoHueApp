//
//  DemoHueRemoteApp.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 13/07/2020.
//

import SwiftUI

@main
struct DemoHueRemoteApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
              store: .init(
                initialState: RootState(),
                reducer: rootReducer,
                environment: .live
              )
            )
        }
    }
}
