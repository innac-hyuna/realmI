//
//  SimpleTableViewCell.swift
//  testAlbom
//
//  Created by FE Team TV on 5/31/16.
//  Copyright © 2016 courses. All rights reserved.
//

import UIKit
import SnapKit

class WantlistTableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    var floatRatingView: FloatRatingView!
    var year: UILabel!
    var textFormat: UILabel!
    var deleteButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    
   override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        contentView.backgroundColor = UIColor.tableColor()
           
        titleLabel = UILabel()
        titleLabel.numberOfLines = 2    
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.textColor = UIColor.textColor()
        titleLabel.font =  UIFont.HelTextFontBold(14)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        floatRatingView = FloatRatingView()
        floatRatingView.emptyImage = UIImage.raitingImage("empty")
        floatRatingView.fullImage =  UIImage.raitingImage("full")
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 5
        floatRatingView.minRating = 1
        floatRatingView.editable = false
        floatRatingView.halfRatings = false
        floatRatingView.floatRatings = false
        floatRatingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(floatRatingView)
    
        year = UILabel()
        year.textColor = UIColor.textColor()
        year.font =  UIFont.HelTextFont(14)
        contentView.addSubview(year)
        year.translatesAutoresizingMaskIntoConstraints = false
    
        textFormat = UILabel()
        textFormat.textColor = UIColor.titleColor()
        textFormat.numberOfLines = 2
        textFormat.lineBreakMode = .ByTruncatingTail
        textFormat.font =  UIFont.HelTextFont(16)
        contentView.addSubview(textFormat)
        textFormat.translatesAutoresizingMaskIntoConstraints = false
    
     
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func setupLayout () {
        
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(5)
            make.width.equalTo(contentView).offset(-100) }
        
        textFormat.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.width.equalTo(contentView).offset(-80) }
        
        year.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView.snp_bottom).offset(-5)
            make.width.equalTo(40) }
        
        floatRatingView.snp_makeConstraints { (make) -> Void in
            make.trailing.equalTo(contentView.snp_trailing).offset(-25)
            make.bottom.equalTo(contentView.snp_bottom).offset(10)
            make.height.equalTo(30)
            make.width.equalTo(60) }

    }

}
