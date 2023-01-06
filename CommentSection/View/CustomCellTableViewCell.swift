//
//  CustomCellTableViewCell.swift
//  CommentSection
//
//  Created by Matthew Gill on 1/3/23.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {
    
    func configure(with model: DataModel) {
        var customContentConfig = defaultContentConfiguration()
        
        if let model = model as? User {
            customContentConfig.text = model.name
            customContentConfig.textProperties.color = .black
            customContentConfig.textProperties.font = .monospacedSystemFont(ofSize: 18, weight: .light)
        }
        
        if let model = model as? Post {
            customContentConfig.text = model.title
            customContentConfig.textProperties.color = .black
            customContentConfig.textProperties.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        }
        
        if let model = model as? Comment {
            customContentConfig.text = model.name
            customContentConfig.secondaryText = nil
            if model.isExpanded {
                customContentConfig.secondaryText = "\(model.email)\n\n\(model.body)"
            }
            customContentConfig.textProperties.color = .black
            customContentConfig.textProperties.font = .monospacedSystemFont(ofSize: 12, weight: .light)
        }
        
        contentConfiguration = customContentConfig
    }
    
}
