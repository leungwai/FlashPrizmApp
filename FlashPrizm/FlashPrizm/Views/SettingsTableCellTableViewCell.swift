//
//  SettingsTableCellTableViewCell.swift
//  FlashPrizm
//
//  Created by HowardWu on 3/26/23.
//

import UIKit

class SettingsTableCellTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set the cell's frame to a custom height value
//        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 60.0)
        
        self.backgroundColor = .clear
        
        // Add UI elements to contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        // Setup truncating for the subtitles (user information)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.lineBreakMode = .byTruncatingTail
        
        // Configure UI elements
        titleLabel.font = UIFont(name: "Gilmer Bold", size: 16)
        titleLabel.textColor = .white
        subtitleLabel.font = UIFont(name: "Garet-Book", size: 16)
        subtitleLabel.textColor = .systemGray5
        
        // Set up constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 120.0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
