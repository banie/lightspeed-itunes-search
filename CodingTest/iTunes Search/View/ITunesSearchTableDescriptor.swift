//
//  iTunesSearchTableDescriptor.swift
//  CodingTest
//

import Foundation
import UIKit
import PureLayout

class ITunesSearchTableDescriptor: NUOTableDescriptor {

    lazy var searchTextField: UITextField = {
        let searchTextField = UITextField()
        searchTextField.borderStyle = .roundedRect
        searchTextField.placeholder = NSLocalizedString("Enter Search term here", comment: "Enter Search term here")
        return searchTextField
    }()

    lazy var searchTextFieldContainerView: UIView = {
        let containerView = UIView()
        containerView.addSubview(self.searchTextField)
        self.searchTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        self.searchTextField.returnKeyType = .search
        self.searchTextField.delegate = self
        return containerView
    }()

    private var searchResults: [iTunesContent]
    private let searchApi: iTunesSearchApi
    
    init(searchApi: iTunesSearchApi = iTunesSearchInteractor()) {
        self.searchApi = searchApi
        searchResults = []
        super.init()
        title = NSLocalizedString("Search iTunes", comment: "Search iTunes")
        shouldReloadTableOnFirstAppearance = true
    }

    override func willAppear() {
        super.willAppear()
        self.delegate?.setContainerHeaderContents([searchTextFieldContainerView])
        self.delegate?.setContainerHeaderContentsDisplayed(true, animated: false)
    }

    @MainActor
    override func loadDescription() {
        if searchResults.isEmpty {
            loadNoResults()
        } else {
            loadResults()
        }
    }

    override func register(with tableView: UITableView) {
        // NO-OP
    }
    
    @MainActor
    private func loadNoResults() {
        var cellDescriptors = [NUOCellDescriptor]()
        let labelCellDescriptor = NUOLabelCellDescriptor()
        labelCellDescriptor.titleText = "No Results ..."
        labelCellDescriptor.leftMargin = 25
        cellDescriptors.append(labelCellDescriptor)
        setCellDescriptors(cellDescriptors, forSection: 0)
    }
    
    @MainActor
    private func loadResults() {
        let cellDescriptors: [NUOCellDescriptor] = searchResults.map { result in
            let contentCellDescriptor = NUOItunesContentCellDescriptor()
            contentCellDescriptor.name = result.trackName ?? "No track name"
            contentCellDescriptor.artistName = result.artistName ?? "No artist name"
            return contentCellDescriptor
        }
        setCellDescriptors(cellDescriptors, forSection: 0)
    }
    
    @MainActor
    private func reloadResults(with results: iTunesSearchResults) {
        searchResults = results.results
        reloadDescription()
        reloadSections(IndexSet(integer: 0))
    }
}

extension ITunesSearchTableDescriptor: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            switch await self.searchApi.search(for: text) {
            case .success(let results):
                await reloadResults(with: results)
            case .failure(let error):
                print("XXXX failure: \(error)")
            }
        }
        
        return true
    }
}
