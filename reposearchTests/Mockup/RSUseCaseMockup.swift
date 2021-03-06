//
//  RSUseCaseMockup.swift
//  reposearchTests
//
//  Created by mellancmyloi on 2022/04/28.
//

#if TEST

import Foundation
import RxSwift


final class RSRepoSearchUseCaseMockup: RSUseCase {
    
    override init() {
        super.init()
    }
}


extension RSRepoSearchUseCaseMockup: RSRepoSearchUseCaseInterface {
    func searchRepos(searchQuery: RSRepoSearchQuery) -> Single<(repos: [RSRepo],
                                                                totalCount: Int64,
                                                                nextPageExists: Bool)> {
        let repo = RSRepo(owner: "",
                          avatarURL: "",
                          name: "",
                          description: "",
                          starCount: 0)
        return .just(([repo], 0, false))
    }
}

#endif
