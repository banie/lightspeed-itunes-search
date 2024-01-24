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
        self.searchTextField.delegate = self
        return containerView
    }()

    private let searchApi: iTunesSearchApi
    
    init(searchApi: iTunesSearchApi = iTunesSearchInteractor()) {
        self.searchApi = searchApi
        super.init()
        title = NSLocalizedString("Search iTunes", comment: "Search iTunes")
        shouldReloadTableOnFirstAppearance = true
    }

    override func willAppear() {
        super.willAppear()
        self.delegate?.setContainerHeaderContents([searchTextFieldContainerView])
        self.delegate?.setContainerHeaderContentsDisplayed(true, animated: false)
    }

    override func loadDescription() {
        var cellDescriptors = [NUOCellDescriptor]()
        let labelCellDescriptor = NUOLabelCellDescriptor()
        labelCellDescriptor.titleText = "No Results ..."
        labelCellDescriptor.leftMargin = 25
        cellDescriptors.append(labelCellDescriptor)
        setCellDescriptors(cellDescriptors, forSection: 0)
    }

    override func register(with tableView: UITableView) {
        // NO-OP
    }
}

extension ITunesSearchTableDescriptor: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return true
        }
        
        let searchTerm = text.replacingCharacters(in: textRange, with: string)
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            switch await self.searchApi.search(for: searchTerm) {
            case .success(let result):
                print("XXXX success: \(result)")
            case .failure(let error):
                print("XXXX failure: \(error)")
            }
        }
        
        return true
    }
}
