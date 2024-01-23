//
//  iTunesSearchTableDescriptorViewController.swift
//  CodingTest
//

import Foundation

class ITunesSearchTableDescriptorViewController: NUOTableDescriptorViewController {
    convenience init() {
        self.init(style: .plain, tableDescriptor: ITunesSearchTableDescriptor())
    }
}
