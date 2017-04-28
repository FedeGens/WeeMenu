//
//  WeeMenu.swift
//  WeeMenu
//
//  Created by Federico Gentile on 20/04/17.
//  Copyright © 2017 Gens. All rights reserved.
//

import UIKit

public class WeeMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    private var menuLeftConst: NSLayoutConstraint!
    private var containerLeftConst: NSLayoutConstraint!
    private var weeMenuView = UIView()
    private var weeMenuShadowView = UIView()
    private var containerView = UIView()
    private var myView = UIView()
    
    private var isMenuOpened: Bool = false
    
    private var screenEdgeRecognizer : UIScreenEdgePanGestureRecognizer!
    private var swipeRecognizer: UIPanGestureRecognizer!
    private var firstLocationX: CGFloat!
    
    private var isStatusBarHidden = false
    
    public var animationDuration: Double = 0.3
    public var roundCorners: Bool = true
    public var roundCornersValue: Double = 8
    public var shadowVisible: Bool = true
    public var rootViewAnimation: RootViewAnimationType = .scale
    public var menuPosition: WeeMenuPosition = .front
    
    public var animateStatusBar: Bool = true {
        didSet {
            if animateStatusBar {
                overlapStatusBar = false
            }
        }
    }
    public var overlapStatusBar: Bool = false {
        didSet {
            if animateStatusBar {
                overlapStatusBar = false
            }
        }
    }
    
    public var rootViewBackgroundColor: UIColor = .white {
        didSet {
            myView.backgroundColor = rootViewBackgroundColor
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Change RootView
        myView = UIView()
        myView.frame = view.frame
        containerView = self.view
        self.view = myView
        self.view.addSubview(containerView)
    }
    
    public func setWeeMenu(ViewController vc: UIViewController) {
        weeMenuView = vc.view
        weeMenuView.clipsToBounds = true
        
        weeMenuShadowView.backgroundColor = .black
        weeMenuShadowView.alpha = 0
        weeMenuShadowView.isHidden = true
        
        weeMenuView.translatesAutoresizingMaskIntoConstraints = false
        weeMenuShadowView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(weeMenuShadowView)
        self.view.addSubview(weeMenuView)
        
        if menuPosition == .front {
            self.view.bringSubview(toFront: weeMenuView)
        } else {
            self.view.bringSubview(toFront: containerView)
        }
        
        setWeeMenuControllerConstraints()
        setWeeMenuOptions()
        
        //setup recognizers
        let tap = UITapGestureRecognizer(target: self, action:#selector(handleBlurTap))
        weeMenuShadowView.addGestureRecognizer(tap)
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.openMenuFromSwipe))
        screenEdgeRecognizer.edges = .left
        screenEdgeRecognizer.delegate = self
        self.view.addGestureRecognizer(screenEdgeRecognizer)
        
        swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.closeMenuFromSwipe))
        swipeRecognizer.delegate = self
        self.view.addGestureRecognizer(swipeRecognizer)
    }
    
    public func openMenu() {
        showMenu(canShow: true, duration: animationDuration)
    }
    
    public func closeMenu() {
        showMenu(canShow: false, duration: animationDuration)
    }
    
    func setWeeMenuOptions() {
        if shadowVisible {
            if menuPosition == .front {
                weeMenuShadowGenericSetting(layerObj: weeMenuView.layer, opacity: 0.5)
            } else {
                weeMenuShadowGenericSetting(layerObj: containerView.layer, opacity: 0.5)
            }
        }
        
        if roundCorners {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: weeMenuView.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: roundCornersValue, height: roundCornersValue)).cgPath
            weeMenuView.layer.mask = maskLayer
        }
    }
    
    //MARK: Constraints
    func setWeeMenuControllerConstraints() {
        //Shadow constraints
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuShadowView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuShadowView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuShadowView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: (overlapStatusBar) ? -20 : 0))
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuShadowView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0))
        
        //Menu constraints
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.width*0.8))
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: (overlapStatusBar) ? -20 : 0))
        self.view.addConstraint(NSLayoutConstraint(item: weeMenuView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0))
        
        menuLeftConst = NSLayoutConstraint(item: weeMenuView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: (menuPosition == .front) ? -self.view.frame.width*0.8 : 0)
        self.view.addConstraint(menuLeftConst)
        
        //Container constraints
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        containerLeftConst = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        self.view.addConstraint(containerLeftConst)
        
        self.view.layoutIfNeeded()
    }
    
    
    //MARK: Menu Interaction Swift
    func showMenu(canShow: Bool, duration: Double) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.showStatusBar(canShow: !canShow)
        
        if menuPosition == .front {
            menuLeftConst.constant = (canShow) ? 0 : -weeMenuView.frame.width
        }else {
            containerLeftConst.constant = (canShow) ? weeMenuView.frame.width : 0
        }
        
        let alpha : CGFloat = (canShow) ? 0.6 : 0
        self.weeMenuShadowView.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.weeMenuShadowView.alpha = alpha
            self.animateRootView(percentage: (canShow) ? 1 : 0, all: false)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.weeMenuView.isHidden = false
            self.weeMenuShadowView.isHidden = !canShow
            self.isMenuOpened = canShow
            UIApplication.shared.endIgnoringInteractionEvents()
        })
        
        animateRootViewFrom(canShow: canShow)
    }
    
    func handleBlurTap() {
        showMenu(canShow: false, duration: animationDuration)
    }
    
    //Open Menu
    func openMenuFromSwipe() {
        if isMenuOpened {
            return
        }
        
        switch screenEdgeRecognizer.state.rawValue {
        case 1:
            firstLocationX = screenEdgeRecognizer.location(in: self.view).x
            if menuPosition == .front {
                weeMenuShadowView.isHidden = false
            }
            showStatusBar(canShow: false)
            break
        case 2:
            let offsetX = screenEdgeRecognizer.location(in: self.view).x - firstLocationX
            checkOpenMenuOrContainer(offsetX: offsetX)
            break
        case 3:
            showMenu(canShow: (menuLeftConst.constant > -weeMenuView.frame.width+80) ? true : false, duration: animationDuration - Double((weeMenuView.frame.width+menuLeftConst.constant)/weeMenuView.frame.width) * animationDuration)
            break
        default:
            print("default")
        }
    }
    
    func checkOpenMenuOrContainer(offsetX: CGFloat) {
        if offsetX > weeMenuView.frame.width {
            if menuPosition == .front {
                menuLeftConst.constant = 0
                self.weeMenuShadowView.alpha = 0.6
            } else {
                containerLeftConst.constant = weeMenuView.frame.width
            }
        } else {
            if menuPosition == .front {
                menuLeftConst.constant = -weeMenuView.frame.width+offsetX
                let percentage = offsetX/weeMenuView.frame.width
                self.weeMenuShadowView.alpha = percentage*0.6
                animateRootView(percentage: percentage, all: true)
            } else {
                containerLeftConst.constant = offsetX
                if containerLeftConst.constant < 0 {
                    containerLeftConst.constant = 0
                }
                self.view.setNeedsLayout()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    //Close Menu
    func closeMenuFromSwipe() {
        if !isMenuOpened {
            return
        }
        switch swipeRecognizer.state.rawValue {
        case 1:
            firstLocationX = swipeRecognizer.location(in: self.view).x
            weeMenuShadowView.isHidden = false
            break
        case 2:
            if firstLocationX < weeMenuView.frame.width - 80 {
                return
            }
            let offsetX = swipeRecognizer.location(in: self.view).x - firstLocationX
            checkCloseMenuOrContainer(offsetX: offsetX)
            break
        case 3:
            showMenu(canShow: (menuLeftConst.constant > -80) ? true : false, duration: Double((weeMenuView.frame.width+menuLeftConst.constant)/weeMenuView.frame.width) * animationDuration)
            break
        default:
            print("default")
        }
    }
    
    func checkCloseMenuOrContainer(offsetX: CGFloat) {
        if offsetX > 0 {
            if menuPosition == .front {
                menuLeftConst.constant = 0
                self.weeMenuShadowView.alpha = 0.6
            } else {
                containerLeftConst.constant = self.weeMenuView.frame.width
            }
        } else {
            if menuPosition == .front {
                menuLeftConst.constant = offsetX
                let percentage = -offsetX/weeMenuView.frame.width
                self.weeMenuShadowView.alpha = 0.6 - percentage*0.6
                animateRootView(percentage: 1-percentage, all: true)
            } else {
                containerLeftConst.constant = self.weeMenuView.frame.width + offsetX
                if containerLeftConst.constant < 0 {
                    containerLeftConst.constant = 0
                }
                self.view.setNeedsLayout()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    //MARK: Animate Root View
    func animateRootView(percentage: CGFloat, all: Bool) {
        switch rootViewAnimation {
        case .scale:
            let scale = 0.02*percentage
            self.containerView.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
            self.containerView.frame.origin = CGPoint(x: -2*percentage, y: self.containerView.frame.origin.y)
            if all {
                self.containerView.layer.cornerRadius = 8*percentage
            }
        case .none: break
        }
    }
    
    func animateRootViewFrom(canShow: Bool) {
        if rootViewAnimation == .scale {
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = self.containerView.layer.cornerRadius
            animation.toValue = (canShow) ? 8 : 0
            animation.duration = 0.3
            self.containerView.layer.add(animation, forKey: "cornerRadius")
            self.containerView.layer.cornerRadius = (canShow) ? 8 : 0
        }
    }
    
    
    //MARK: Gesture Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isMenuOpened && gestureRecognizer == swipeRecognizer {
            return false
        }
        return true
    }
    
    
    //MARK: Shadow
    func weeMenuShadowGenericSetting(layerObj: CALayer , opacity :Float) {
        layerObj.masksToBounds = false
        layerObj.shouldRasterize = false
        layerObj.shadowOpacity = opacity
        layerObj.shadowRadius = 1.5
        layerObj.shadowColor = UIColor.black.cgColor
        layerObj.shadowOffset = CGSize(width: 0.0, height: 1.5)
    }
    
    
    //MARK: StatusBar Appearance
    func showStatusBar(canShow: Bool) {
        guard animateStatusBar else {
            return
        }
        isStatusBarHidden = !canShow
        UIView.animate(withDuration: animationDuration, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    override public var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    
    //MARK: Detect Rotation
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !isMenuOpened {
            weeMenuView.isHidden = true
        }
        self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.containerView.frame = myView.frame
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.showMenu(canShow: false, duration: self.animationDuration)
        })
    }
    
}

public enum RootViewAnimationType {
    case none
    case scale
}

public enum WeeMenuPosition {
    case front
    case behind
}
