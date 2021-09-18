//
//  RestaurantCell.swift
//  HungerNoMore
//
//  Created by QUANG on 5/29/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import Cosmos
import FaceAware
import MarqueeLabel
import ChameleonFramework

class RestaurantCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var lblName: MarqueeLabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var restaurantIconView: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var featuredImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        ratingView.settings.updateOnTouch = false
        
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize.zero
        
        let darkLenseView = UIView(frame: featuredImage.bounds)
        darkLenseView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        featuredImage.addSubview(darkLenseView)
        
        restaurantIconView.layer.cornerRadius = 5
        
        self.backgroundColor = RandomFlatColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
