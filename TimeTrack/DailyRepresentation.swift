//
//  DailyRepresentation.swift
//  TimeTrack
//
//  Created by Kenneth Jones on 12/6/20.
//

import Foundation

struct DailyRepresentation: Codable {
    var action: String
    var time: Date
    var notes: String?
}
