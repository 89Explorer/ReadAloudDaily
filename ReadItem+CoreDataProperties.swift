//
//  ReadItem+CoreDataProperties.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//
//

import Foundation
import CoreData


extension ReadItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadItem> {
        return NSFetchRequest<ReadItem>(entityName: "ReadItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var dailyReadingTime: Double
    @NSManaged public var isCompleted: Bool

}

extension ReadItem : Identifiable {

}
