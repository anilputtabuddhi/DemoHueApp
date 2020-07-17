//
//  ObjectPersistor.swift
//  DemoHueRemote
//
//  Created by Anil Puttabuddhi on 15/07/2020.
//

import Foundation

protocol ObjectPersistor {
    func object<T: Codable>(forKey defaultName: String) -> T?
    func set<T: Codable>(_ value: T?, forKey defaultName: String)
}

struct UserDefaultObjectPersistor: ObjectPersistor {

    private let defaults: UserDefaults = UserDefaults.standard

    func object<T: Codable>(forKey defaultName: String) -> T? {
        if let data = defaults.object(forKey: defaultName) as? Data,
           let object = try? JSONDecoder().decode(T.self, from: data) {
                return object
        }
        return nil
    }

    func set<T: Codable>(_ value: T?, forKey defaultName: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            defaults.set(encoded, forKey: defaultName)
        }
    }
}


class MockObjectPersistor: ObjectPersistor {

    private var defaults = Dictionary<String, Any>()

    func object<T: Codable>(forKey defaultName: String) -> T? {
        return defaults[defaultName] as? T
    }

    func set<T: Codable>(_ value: T?, forKey defaultName: String) {
        defaults[defaultName] = value
    }
}
