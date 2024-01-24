//
//  NUOItunesContentCell.swift
//  CodingTest
//
//  Created by banie setijoso on 2024-01-24.
//

import Foundation
import UIKit

class NUOItunesContentCell: UITableViewCell {
    var image: UIImageView = UIImageView()
    var name: UILabel = UILabel()
    var artistName: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(image)
        contentView.addSubview(name)
        contentView.addSubview(artistName)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        artistName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            name.bottomAnchor.constraint(equalTo: artistName.topAnchor, constant: 5),
            name.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            
            artistName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            artistName.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
