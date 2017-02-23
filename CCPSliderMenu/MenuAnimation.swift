//
//  MenuAnimation.swift
//  CCPSliderMenu
//
//  Created by 储诚鹏 on 17/2/23.
//  Copyright © 2017年 chuchengpeng. All rights reserved.
//

import UIKit


private func rotationTransform(_ layer : CALayer, angle : CGFloat) -> CATransform3D {
    let offset = layer.bounds.width / 2
    var transform = CATransform3DIdentity
    //m34负责z轴移动，m34 = -1 / D,D是观察者与投影面的距离(近大远小)
    transform.m34 = -0.002 //D = 500
    transform = CATransform3DTranslate(transform, -offset, 0, 0)
    transform = CATransform3DRotate(transform, angle, 0, 1, 0)
    transform = CATransform3DTranslate(transform, offset, 0, 0)
    return transform
}

class MenuAnimation: NSObject {
    
    var completion : () -> Void = {}
    var duration: CFTimeInterval = 0
    //fileprivate表示在当前文件内私有，也就是说当前文件可以用
    fileprivate let layers : [CALayer]
    fileprivate let startAngle : CGFloat
    fileprivate let endAngle : CGFloat
    
    init(views: [UIView], startAngle: CGFloat, endAngle: CGFloat) {
        self.layers = views.map {$0.layer}
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
    
    func start() {
        let count = Double(layers.count)
        let menuDuration = self.duration * count / (4 * count - 3)
        for (index, layer) in layers.enumerated() {
            layer.transform = rotationTransform(layer, angle: startAngle)
            let delay = 3 * menuDuration * Double(index) / count
            UIView.animate(withDuration: menuDuration, delay: delay, options: .curveEaseIn, animations: { 
                layer.transform = rotationTransform(layer, angle: self.endAngle)
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: { 
                self.completion()
            })
        }
    }
    
}
