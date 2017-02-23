//
//  MenuTransitionAnimation.swift
//  CCPSliderMenu
//
//  Created by 储诚鹏 on 17/2/23.
//  Copyright © 2017年 chuchengpeng. All rights reserved.
//

import UIKit



open class MenuTransitionAnimation: NSObject {
    @objc public enum Mode : Int {case presentation, dismissal}
    
    fileprivate let duration = 0.5
    fileprivate let angle : CGFloat = 2
    fileprivate var mode : Mode
    fileprivate var shouldPassEventOutsideMenu : Bool
    fileprivate var tapOutsideHandler : (() -> Void)?
    
    public init(mode : Mode, shouldPassEventOutsideMenu : Bool = true, tapOutsideHandler : (() -> Void)? = nil) {
        self.mode = mode
        self.tapOutsideHandler = tapOutsideHandler
        self.shouldPassEventOutsideMenu = shouldPassEventOutsideMenu
        super.init()
    }
}

extension MenuTransitionAnimation {
    @objc fileprivate func tapOutsideHandler(_ sender : UIButton) {
        if tapOutsideHandler != nil {
            tapOutsideHandler!()
        }
    }
}

extension MenuTransitionAnimation {
    
    fileprivate func dismissAnimation(using context : UIViewControllerContextTransitioning) {
        if let menu = context.viewController(forKey: .from) {
            animate(menu as! menuViews, startAngle: 0, endAngle: angle, completion: { 
                menu.view.removeFromSuperview()
                context.completeTransition(true)
            })
        }
    }
    
    fileprivate func animate(_ menu : menuViews, startAngle : CGFloat, endAngle : CGFloat, completion : @escaping () -> Void) {
        let animator = MenuAnimation(views: menu.menuItems, startAngle: startAngle, endAngle: endAngle)
        animator.duration = duration
        animator.completion = completion
        animator.start()
    }
    
    fileprivate func presentAnimation(using context : UIViewControllerContextTransitioning) {
        let host = context.viewController(forKey: .from)!
        let menu = context.viewController(forKey: .to)!
        let view = menu.view!
        view.frame = CGRect(x: 0, y: 0, width: menu.preferredContentSize.width, height: host.view.bounds.height)
        view.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        if shouldPassEventOutsideMenu {
            context.containerView.frame = view.frame
        }
        else {
            let tapButton = UIButton(frame: host.view.frame)
            tapButton.backgroundColor = .clear
            tapButton.addTarget(self, action: #selector(tapOutsideHandler(_:)), for: .touchUpInside)
            context.containerView.addSubview(tapButton)
        }
        context.containerView.addSubview(view)
        animate(menu as! menuViews, startAngle: angle, endAngle: 0) { 
            context.completeTransition(true)
        }
    }
}

extension MenuTransitionAnimation : UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch mode {
        case .presentation:
            presentAnimation(using: transitionContext)
        case .dismissal:
            dismissAnimation(using: transitionContext)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
