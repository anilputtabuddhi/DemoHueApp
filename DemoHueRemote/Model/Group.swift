//
//  Group.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 11/07/2020.
//

import Foundation

struct Group: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    var lights: [Light]
}

//MARK: - Comparable
extension Group: Comparable {
    public static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.name < rhs.name
    }
}

//MARK: - Derived Properties
extension Group {

    var brightness: Int {
        get {
            lights.map(\.brightness).reduce(0, +) / lights.count
        }
        set {
            lights = lights.map { return $0.newlightWith(brightness: newValue) }
        }
    }

    var isAnyLightOn: Bool {
        get {
            lights.map(\.isOn).reduce(false) { $0 || $1 }
        }
        set {
            lights = lights.map { return $0.newlightWith(isOn: newValue) }
        }
    }

    var isAnyLightReachable: Bool {
        lights.filter(\.reachable).count != 0
    }

    var imageName: String {
        return "house"
    }

    var canControl: Bool {
        return isAnyLightReachable && isAnyLightOn
    }

    var status: String {
        get {
            guard isAnyLightReachable else {
                return "No lights reachable"
            }
            let onCount = lights.filter{ $0.isOn }.count
            switch onCount {
            case 0:
                return "All lights are off"
            case lights.count:
                return "All lights are on"
            case 1:
                return "1 light is on"
            default:
                return "\(onCount) lights are on"
            }
        }
    }
}

//MARK: - Helpers
extension Group {
    static func createGroupListWith(
        groupDictionary: GroupDictionary,
        lightsDictionary: LightDictionary) -> [Group] {

        return groupDictionary.map { key, group in
            let lights = group.lights.compactMap { lightId -> Light? in
                guard let lightDto = lightsDictionary[lightId] else {
                    return nil
                }
                return Light.createLightWith(lightId: lightId, lightDto: lightDto)
            }
            return Group(id: key, name: group.name, lights: lights)
        }
    }

    func newGroupWith(_ lights: [Light]) -> Group {
        var newGroup = self
        newGroup.lights = lights
        return newGroup
    }
}


//MARK: - Mock Data

extension Group {

    static var testGroups: [Group] = {
        return [
            Group(
                id: "\(UUID())",
                name: "Living Room",
                lights: Array(Light.testLights[0...2])
            ),
            Group(
                id: "\(UUID())",
                name: "Kitchen",
                lights: Array(Light.testLights[3...5])
            ),
            Group(
                id: "\(UUID())",
                name: "Hall",
                lights: Array(Light.testLights[6...9])
            ),
       ]
    }()
}
