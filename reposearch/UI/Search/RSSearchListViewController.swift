//
//  RSSearchListViewController.swift
//  reposearch
//
//  Created by mellancmyloi on 2022/04/27.
//

import UIKit
import RxSwift
import RxCocoa


fileprivate extension RSSearchOrder {
    var toggledValue: RSSearchOrder {
        switch self {
        case .desc:
            return .asc
        case .asc:
            return .desc
        }
    }
}


class RSSearchListViewController: RSViewController<RSSearchListViewModel> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableIndicatorBackgroundView: RSSearchTableIndicatorBackgroundView!
    @IBOutlet var tableEmptyBackgroundView: RSSearchTableEmptyBackgroundView!
    
    @IBOutlet weak var orderButton: UIButton!
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()
    
    func setSearchText(_ text: String) {
        self.viewModel.setSearchText(text)
    }
    
    func setSearchSort(_ sort: RSSearchSort) {
        self.viewModel.setSearchSort(sort)
    }
    
    func setPerPage(_ perPage: Int64) {
        self.viewModel.setPerPage(perPage)
    }
    
    override func initView() {
        super.initView()
        
        self.tableView.refreshControl = self.refreshControl
        
        self.orderButton.layer.cornerRadius = 40.0 / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.viewModel.refresh()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.searchResult
            .asObservable()
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, result in
                vc.tableView.reloadData()
                vc.refreshControl.endRefreshing()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.order
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, order in
                let transform: CGAffineTransform
                
                switch order {
                case .desc:
                    transform = CGAffineTransform(rotationAngle: -180.0 / 180.0 * CGFloat.pi)
                case .asc:
                    transform = .identity
                }
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut]) {
                    vc.orderButton.transform = transform
                }
            })
            .disposed(by: self.disposeBag)
        
        self.orderButton.rx.controlEvent(.touchUpInside)
            .asObservable()
            .withLatestFrom(self.viewModel.order)
            .map { $0.toggledValue }
            .bind(to: self.viewModel.order)
            .disposed(by: self.disposeBag)
        
        self.viewModel.sort
            .asObservable()
            .map { ($0 == .bestMatch) ? true : false }
            .observe(on: MainScheduler.instance)
            .bind(to: self.orderButton.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
}


extension RSSearchListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.viewModel.searchResult.value {
        case .blank:
            tableView.backgroundView = nil
            self.tableIndicatorBackgroundView.indicatorView.stopAnimating()
            return 0
            
        case .searching:
            tableView.backgroundView = self.tableIndicatorBackgroundView
            self.tableIndicatorBackgroundView.indicatorView.startAnimating()
            return 0
            
        case .result:
            tableView.backgroundView = nil
            self.tableIndicatorBackgroundView.indicatorView.stopAnimating()
            return 1
            
        case .emptyResult:
            tableView.backgroundView = self.tableEmptyBackgroundView
            self.tableIndicatorBackgroundView.indicatorView.stopAnimating()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewModel.searchResult.value {
        case .blank, .searching, .emptyResult:
            return 0
            
        case .result(let repos, _, _, let nextPageExists):
            return repos.count + (nextPageExists ? 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case .result(let repos, _, _, _) = self.viewModel.searchResult.value else {
            fatalError()
        }
        
        if repos.indices.contains(indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.rsSearchTableViewCellDefault, for: indexPath)!
            let repo = repos[indexPath.row]
            
            if let urlString = repo.avatarURL, let url = URL(string: urlString) {
                RSImageDownloadUseCaseFactory.instance.downloadImage(url: url)
                    .asObservable()
                    .observe(on: MainScheduler.asyncInstance)
                    .bind(to: cell.thumbnailImageView.rx.image)
                    .disposed(by: cell.disposeBag)
            }
            
            cell.ownerLabel.text = repo.owner ?? ""
            cell.titleLabel.text = repo.name ?? ""
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.28
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attributedString = NSAttributedString(string: repo.description ?? "", attributes: [
                .font: UIFont.systemFont(ofSize: 17.0, weight: .regular) as Any,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ])
            
            cell.descriptionLabel.attributedText = attributedString
            cell.starLabel.text = repo.starCount?.description ?? ""
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.rsSearchTableViewCellNextPage, for: indexPath)!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case .result(let repos, _, _, let nextPageExists) = self.viewModel.searchResult.value,
           (repos.indices.contains(indexPath.row) != true) && nextPageExists {
            (cell as? RSSearchTableViewCellNextPage)?.indicatorView.startAnimating()
            self.viewModel.requestNextPage()
        }
    }
}


extension RSSearchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .result(_, let totalCount, _, _) = self.viewModel.searchResult.value else {
            return nil
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.rsSearchTableViewCellSectionHeader.identifier) as! RSSearchTableViewCellSectionHeader
        cell.titleLabel.text = "\(totalCount) repositories found."
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard case .result(let repos, _, _, _) = self.viewModel.searchResult.value else {
            return 0.0
        }
        
        if repos.indices.contains(indexPath.row) {
            let repo = repos[indexPath.row]
            return RSSearchTableViewCellDefault.getCellHeight(by: repo.description ?? "",
                                                              cellWidth: tableView.bounds.width)
            
        } else {
            return RSSearchTableViewCellNextPage.getCellHeight()
        }
    }
}
