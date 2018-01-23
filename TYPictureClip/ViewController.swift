//
//  ViewController.swift
//  TYPictureClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 zhaotaoyuan. All rights reserved.
//

import UIKit

public let screenWidth = UIScreen.main.bounds.width
public let screenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {

    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: (screenWidth - 200)/2.0, y: 100, width: 200, height: 50)
        btn.backgroundColor = UIColor.red
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.tag = 100
        btn.addTarget(self, action: #selector(selectImage(sender:)), for: .touchUpInside)
        btn.setTitle("切割", for: .normal)
        view.addSubview(btn)
        
        imageView = UIImageView()
        imageView.frame = CGRect(x: (screenWidth - 200)/2.0, y: btn.frame.maxY + 30, width: 200, height: 200)
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = UIColor.gray
        view.addSubview(imageView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func selectImage(sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.mediaTypes = ["public.image"]
        present(vc, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let vc = PhotoClipViewController.init(image: image)!
        vc.clipWidth = 300
        vc.clipHeight = 300 * 0.65
        vc.delegate = self
        picker.navigationBar.isHidden = false
        picker.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: PhotoClipViewControllerDelegate {
    func photoClipController(_ controller: PhotoClipViewController!, didFinishWithCroppedImage croppedImage: UIImage!) {
        self.imageView.image = croppedImage
        controller.dismissToRootViewController()
    }
    
    func photoClipControllerDidCancel(_ controller: PhotoClipViewController!) {
        controller.dismissToRootViewController()
    }
}




