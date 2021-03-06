//
//  Author+Database.swift
//  Database
//
//  Created by Brent Simmons on 7/8/17.
//  Copyright © 2017 Ranchero Software. All rights reserved.
//

import Foundation
import Data
import RSDatabase

extension Author {

	init?(row: FMResultSet) {
		
		let databaseID = row.string(forColumn: DatabaseKey.databaseID)
		let name = row.string(forColumn: DatabaseKey.name)
		let url = row.string(forColumn: DatabaseKey.url)
		let avatarURL = row.string(forColumn: DatabaseKey.avatarURL)
		let emailAddress = row.string(forColumn: DatabaseKey.emailAddress)

		self.init(databaseID: databaseID, name: name, url: url, avatarURL: avatarURL, emailAddress: emailAddress)
	}
}
