//
//  UIImage+Clip.swift
//  TYPictureClip
//
//  Created by zhaotaoyuan on 2018/1/22.
//  Copyright © 2018年 DoMobile21. All rights reserved.
//

import UIKit

class UIImage_Clip: NSObject {

}

extension UIViewController {
    func dismissToRootViewController() {
        var vc: UIViewController? = self.presentingViewController
        var viewC: UIViewController?
        while vc != nil
        {
            vc = vc?.presentingViewController
            viewC = vc != nil ? vc : viewC
        }
        viewC?.dismiss(animated: true, completion: nil)
    }
}
