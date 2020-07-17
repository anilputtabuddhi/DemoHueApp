//
//  HueBridge.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation

struct HueBridge: Codable, Equatable, CustomStringConvertible {

    let id: String
    let internalipaddress: String

    var description: String {
        "[Hue Bridge ID: \(id), IP Address: \(internalipaddress)]"
    }
}

//MARK: - Mock Data

extension HueBridge {

    static var testBridges: [HueBridge] = {
        [
            HueBridge(id: "\(UUID())", internalipaddress: "192.168.1.120"),
            HueBridge(id: "\(UUID())", internalipaddress: "192.168.1.129")
        ]
    }()
    
}
