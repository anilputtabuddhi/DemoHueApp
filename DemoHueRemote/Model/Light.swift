//
//  Light.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//
import Foundation

struct Light: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    var isOn: Bool
    var brightness: Int
    var colorTemperature: Int
    let reachable: Bool
}

//MARK: - Derived Properties
extension Light {
    var imageName: String {
        return "lightbulb"
    }

    var status: String? {
        get {
            reachable ? nil : "Light not reachable"
        }
    }
}

//MARK: - Comparable
extension Light: Comparable {
    static func < (lhs: Light, rhs: Light) -> Bool {
        lhs.name < rhs.name
    }
}

//MARK: - Helpers
extension Light {

    static func createLightWith(lightId: String, lightDto: LightDTO) -> Light {
        Light(id: lightId,
              name: lightDto.name,
              isOn: lightDto.state.on,
              brightness: lightDto.state.bri,
              colorTemperature: lightDto.state.ct,
              reachable: lightDto.state.reachable)
    }

    func newlightWith(isOn: Bool) -> Light {
        var newLight = self
        newLight.isOn = isOn
        return newLight
    }

    func newlightWith(brightness: Int) -> Light {
        var newLight = self
        newLight.brightness = brightness
        return newLight
    }
}

//MARK: - Mock Data
extension Light {

    static var testLights: [Light] = {
        (1...10).map {
            Light(
                id: "\($0)",
                name: "Light \($0)",
                isOn: Bool.random(),
                brightness: Int.random(in: 0..<255),
                colorTemperature: Int.random(in: 153..<455),
                reachable: true
            )
        }
    }()
}
