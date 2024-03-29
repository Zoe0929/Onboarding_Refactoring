//
//  UIView+.swift
//  MyMusicApp
//
//  Created by 지희의 MAC on 2023/06/16.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
