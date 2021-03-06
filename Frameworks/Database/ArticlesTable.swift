//
//  ArticlesTable.swift
//  Evergreen
//
//  Created by Brent Simmons on 5/9/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSDatabase
import Data

final class ArticlesTable: DatabaseTable {

	let name: String
	let queue: RSDatabaseQueue
	private let cachedArticles: NSMapTable<NSString, Article> = NSMapTable.weakToWeakObjects()

	init(name: String, queue: RSDatabaseQueue) {

		self.name = name
		self.queue = queue
	}

	func uniquedArticles(_ fetchedArticles: Set<Article>, statusesTable: StatusesTable) -> Set<Article> {
		
		var articles = Set<Article>()
		
		for oneArticle in fetchedArticles {
			
			assert(oneArticle.status != nil)
			
			if let existingArticle = cachedArticle(oneArticle.databaseID) {
				articles.insert(existingArticle)
			}
			else {
				cacheArticle(oneArticle)
				articles.insert(oneArticle)
			}
		}
		
		statusesTable.attachCachedStatuses(articles)
		
		return articles
	}

	typealias FeedCountCallback = (Int) -> Void

	func numberOfArticlesWithFeedID(_ feedID: String, callback: @escaping FeedCountCallback) {

		queue.fetch { (database: FMDatabase!)

			let sql = "select count(*) from articles where feedID = ?;"
			var numberOfArticles = -1

			if let resultSet = database.executeQuery(sql, withArgumentsIn: [feedID]) {

				while (resultSet.next()) {
					numberOfArticles = resultSet.long(forColumnIndex: 0)
					break
				}
			}

			DispatchQueue.main.async() {
				callback(numberOfArticles)
			}
		}

	}
}

private extension ArticlesTable {

	func cachedArticle(_ articleID: String) -> Article? {

		return cachedArticles.object(forKey: articleID as NSString)
	}

	func cacheArticle(_ article: Article) {

		cachedArticles.setObject(article, forKey: article.databaseID as NSString)
	}

	func cacheArticles(_ articles: Set<Article>) {

		articles.forEach { cacheArticle($0) }
	}
}

