//
//  DataStatus.swift
//  PhilipsHueLightsController
//
//  Created by Anil Puttabuddhi on 13/07/2020.
//

import Foundation

enum DataStatus<T: Equatable>: Equatable {
    case notStarted
    case loading
    case loaded(data: T)
    case failed
}
