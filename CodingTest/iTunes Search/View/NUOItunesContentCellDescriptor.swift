//
//  NUOItunesContentCellDescriptor.swift
//  CodingTest
//
//  Created by banie setijoso on 2024-01-24.
//

import Foundation

class NUOItunesContentCellDescriptor: NUOCellDescriptor {
    
    var name: String?
    var artistName: String?
    var imageUrlString: String?
    
    override class func cellClass() -> AnyClass {
        NUOItunesContentCell.self
    }
    
    override func configureTableViewCell(_ tableViewCell: UITableViewCell, withTableDescriptorObject object: Any?) {
        super.configureTableViewCell(tableViewCell, withTableDescriptorObject: object)
        
        guard let contentCell = tableViewCell as? NUOItunesContentCell else {
            return
        }
        
        contentCell.name.text = name
        contentCell.artistName.text = artistName
    }
}
