//
//  Network.swift
//  HueLightsController
//
//  Created by Anil Puttabuddhi on 10/07/2020.
//

import Combine
import Foundation
import ComposableArchitecture

struct Network {

    struct Response<T> {
        let value: T
        let response: URLResponse
    }

    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> Effect<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    func runWithoutDecoding(_ request: URLRequest) -> Effect<Data, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                return result.data
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }
}
