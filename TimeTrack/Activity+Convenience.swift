//
//  Activity+Convenience.swift
//  TimeTrack
//
//  Created by Kenneth Jones on 12/6/20.
//

import Foundation
import CoreData

extension Activity {
    var activityRepresentation: ActivityRepresentation? {
        guard let activity = activity else { return nil }
        
        return ActivityRepresentation(activity: activity)
    }
    @discardableResult convenience init(activity: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.activity = activity
    }
    
    @discardableResult convenience init?(activityRepresentation: ActivityRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(activity: activityRepresentation.activity, context: context)
    }
}
