//
//  Daily+Convenience.swift
//  TimeTrack
//
//  Created by Kenneth Jones on 12/6/20.
//

import Foundation
import CoreData

extension Daily {
    var dailyRepresentation: DailyRepresentation? {
        guard let action = action else { return nil }
        
        return DailyRepresentation(action: action, time: time ?? Date(), notes: notes)
    }
    @discardableResult convenience init(action: String,
                                        time: Date,
                                        notes: String?,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.action = action
        self.time = time
        self.notes = notes
    }
    
    @discardableResult convenience init?(dailyRepresentation: DailyRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(action: dailyRepresentation.action,
                  time: dailyRepresentation.time,
                  notes: dailyRepresentation.notes,
                  context: context)
    }
}
