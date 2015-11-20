//
//  Test.swift
//  OutlineViewTutorial
//
//  Created by Scott on 12/30/14.
//  Copyright (c) 2014 CrankySoft. All rights reserved.
//

import Foundation
import CoreData

class Test: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var parent: Test
    @NSManaged var children: NSSet

}
