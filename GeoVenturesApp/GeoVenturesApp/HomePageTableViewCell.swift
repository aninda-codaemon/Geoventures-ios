//
//  HomePageTableViewCell.swift
//  GeoVenturesApp
//
//  Created by Cano-n on 15/12/17.
//  Copyright © 2017 Cano-n. All rights reserved.
//

import UIKit

class HomePageTableViewCell: UITableViewCell {
    @IBOutlet var locationImage: UIImageView!
    @IBOutlet var address: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var viewINcell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
