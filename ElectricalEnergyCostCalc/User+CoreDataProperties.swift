//
//  User+CoreDataProperties.swift
//  ElectricalEnergyCostCalc
//
//  Created by Sümeyye Kazancı on 22.08.2022.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var serviceNumber: String?
    @NSManaged public var consumption: NSSet?

}

// MARK: Generated accessors for consumption
extension User {

    @objc(addConsumptionObject:)
    @NSManaged public func addToConsumption(_ value: Consumption)

    @objc(removeConsumptionObject:)
    @NSManaged public func removeFromConsumption(_ value: Consumption)

    @objc(addConsumption:)
    @NSManaged public func addToConsumption(_ values: NSSet)

    @objc(removeConsumption:)
    @NSManaged public func removeFromConsumption(_ values: NSSet)

}

extension User : Identifiable {

}
