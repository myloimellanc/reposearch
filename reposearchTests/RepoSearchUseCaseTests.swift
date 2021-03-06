//
//  RepoSearchUseCaseTests.swift
//  reposearchTests
//
//  Created by mellancmyloi on 2022/04/28.
//

import XCTest
import RxSwift
@testable import reposearch


class RepoSearchUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
         
    }

    func testRepoSearch() throws {
        let searchQuery = try RSRepoSearchQuery(query: "test",
                                                sort: .bestMatch,
                                                order: .desc,
                                                perPage: 30,
                                                page: 1)
        
        let expectation = XCTestExpectation()
        let disposable = RSRepoSearchUseCase().searchRepos(searchQuery: searchQuery)
            .subscribe(onSuccess: { repos, totalCount, nextPageExists in
                expectation.fulfill()
                
            }, onFailure: { error in
                XCTFail(error.localizedDescription)
            })
        
        defer {
            disposable.dispose()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
