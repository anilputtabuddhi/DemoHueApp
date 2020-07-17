//
//  HueAPI.swift
//  HueLightsController
//
//  Created by Anil Puttabuddhi on 10/07/2020.
//

import Foundation
import Combine
import ComposableArchitecture

struct HueAPI {

    let network = Network()
    var authorisedHueBridge: AuthorisedHueBridge?
    var base: URL {
        return URL(string: "http://\(authorisedHueBridge!.hueBridge.internalipaddress)/api/\(authorisedHueBridge!.user)")!
    }

    init(authorisedHueBridge: AuthorisedHueBridge?) {
        self.authorisedHueBridge = authorisedHueBridge
    }
}

typealias GroupDictionary = Dictionary<String, GroupDTO>

struct GroupDTO: Codable {
    let name: String
    let lights: [String]
}

typealias LightDictionary = Dictionary<String, LightDTO>

struct LightDTO: Codable {
    let name: String
    let state: LightStateDTO
}

struct LightStateDTO: Codable {
    let on: Bool
    let bri: Int
    let ct: Int
    let reachable: Bool
}

protocol HueAPIProtocol {
    var isAuthorised: Bool { get }
    func toggleOnFor(group: Group, value: Bool) -> Effect<Bool, Never>
    func setBrightnessFor(group: Group, value: Int) -> Effect<Bool, Never>
    func toggleOnFor(light: Light, value: Bool) -> Effect<Bool, Never>
    func setBrightnessFor(light: Light, value: Int) -> Effect<Bool, Never>
    func setColorTemperatureFor(light: Light, value: Int) -> Effect<Bool, Never>
    func groups() -> Effect<[Group], GroupDataFetchError>
    func lights() -> Effect<[Light], LightsDataFetchError>
}

extension HueAPI: HueAPIProtocol {

    var isAuthorised: Bool {
        authorisedHueBridge != nil
    }

    func toggleOnFor(group: Group, value: Bool) -> Effect<Bool, Never> {
        return group.lights
            .map { setParamsForLight(id: $0.id, jsonObject: ["on": value])}
            .publisher
            .flatMap { $0 }
            .collect()
            .map{ _ in true }
            .eraseToEffect()
    }

    func setBrightnessFor(group: Group, value: Int) -> Effect<Bool, Never> {
        return group.lights
            .map { setParamsForLight(id: $0.id, jsonObject: ["bri": value])}
            .publisher
            .flatMap { $0 }
            .collect()
            .map{ _ in true }
            .eraseToEffect()
    }

    func toggleOnFor(light: Light, value: Bool) -> Effect<Bool, Never> {
        return setParamsForLight(id: light.id, jsonObject: ["on": value])
    }

    func setBrightnessFor(light: Light, value: Int) -> Effect<Bool, Never> {
        return setParamsForLight(id: light.id, jsonObject: ["bri": value])
    }

    func setColorTemperatureFor(light: Light, value: Int) -> Effect<Bool, Never> {
        return setParamsForLight(id: light.id, jsonObject: ["ct": value])
    }

    func groups() -> Effect<[Group], GroupDataFetchError> {
         return Publishers.CombineLatest(groupsDictionary(), lightsDictionary())
            .receive(on: DispatchQueue.main)
            .map{ groupDict, lightsDict  in
                return Group.createGroupListWith(
                    groupDictionary: groupDict,
                    lightsDictionary: lightsDict
                )
            }
            .eraseToAnyPublisher()
            .mapError{ _  in
                GroupDataFetchError.unknown
            }
            .eraseToEffect()
    }

    func lights() -> Effect<[Light], LightsDataFetchError> {
        return lightsDictionary()
            .receive(on: DispatchQueue.main)
            .map{ lightsDictionary in
                return lightsDictionary.map { key, lightDto in
                    Light.createLightWith(lightId: key, lightDto: lightDto)
                }
            }
            .eraseToAnyPublisher()
            .mapError{ _  in
                LightsDataFetchError.unknown
            }
            .eraseToEffect()
    }

    // MARK :- Private Methods
    private func groupsDictionary( ) -> AnyPublisher<GroupDictionary, Error> {
        let request = URLRequest(url: base.appendingPathComponent("groups"))
        return network.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    private func lightsDictionary( ) -> AnyPublisher<LightDictionary, Error> {
        let request = URLRequest(url: base.appendingPathComponent("lights"))
        return network.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    private func setParamsForLight(id: String, jsonObject: Any) -> Effect<Bool, Never> {
        let request = getPutURLRequestFor(pathComponent: "lights/\(id)/state",
                                          jsonObject: jsonObject)

        return network.runWithoutDecoding(request)
            .map{ _ in true }
            .replaceError(with: false)
            .eraseToEffect()
    }

    // This is a really slow performing API - limited to 1 call every 10 seconds.
    // So unused for now. Use setParamsForLight(id: jsonObject:) and make
    // multiple prallel calls instead
    private func setParamsForGroup(id: String, jsonObject: Any) -> Effect<Bool, Never> {
        let request = getPutURLRequestFor(pathComponent: "groups/\(id)/action",
                                          jsonObject: jsonObject)

        return network.runWithoutDecoding(request)
            .map{ _ in true }
            .replaceError(with: false)
            .eraseToEffect()
    }

    private func getPutURLRequestFor(pathComponent: String, jsonObject: Any) -> URLRequest {
        var request = URLRequest(url: base.appendingPathComponent(pathComponent))
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        request.httpBody = try! JSONSerialization.data(
            withJSONObject: jsonObject,
            options: []
        )

        return request
    }

}
