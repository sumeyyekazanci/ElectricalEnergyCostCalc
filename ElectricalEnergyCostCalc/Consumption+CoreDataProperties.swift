//
//  Consumption+CoreDataProperties.swift
//  ElectricalEnergyCostCalc
//
//  Created by Sümeyye Kazancı on 22.08.2022.
//
//

import Foundation
import CoreData


extension Consumption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Consumption> {
        return NSFetchRequest<Consumption>(entityName: "Consumption")
    }

    @NSManaged public var date: String?
    @NSManaged public var value: Double
    @NSManaged public var user: User?

}

extension Consumption : Identifiable {

}
