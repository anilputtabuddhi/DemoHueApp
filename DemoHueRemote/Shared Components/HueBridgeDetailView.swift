//
//  HueBridgeDetailView.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 16/07/2020.
//

import SwiftUI

struct HueBridgeDetailView: View {
    let authBridge: AuthorisedHueBridge
    var body: some View {
        VStack {
            HueBridgeImage(size: 100)
            VStack {
                HStack{
                    Text("IP Address: ")
                    Text(authBridge.hueBridge.internalipaddress)
                }
                Divider()
                HStack{
                    Text("Username: ")
                    Text(authBridge.user)
                }
            }
            .font(.footnote)
            .padding()
        }
    }
}

struct HueBridgeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HueBridgeDetailView(
            authBridge: AuthorisedHueBridge(
                hueBridge: HueBridge.testBridges[0],
                user: "121"
            )
        )
    }
}
