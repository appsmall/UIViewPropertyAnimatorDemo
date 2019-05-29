
//
//  CityCollectionViewCell.swift
//  UIViewPropertyAnimatorDemo
//
//  Created by apple on 28/05/19.
//  Copyright © 2019 appsmall. All rights reserved.
//

import UIKit

private enum State {
    case expanded
    case collapsed
    
    var change: State {
        switch self {
        case .expanded:
            return .collapsed
            
        case .collapsed :
            return .expanded
        }
    }
}

class CityCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    private let cornerRadius: CGFloat = 6
    
    static let cellSize = CGSize(width: 250, height: 350)
    static let identifier = "CityCollectionViewCell"
    
    @IBOutlet weak var cityTitle: UILabel!
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    private var collectionView: UICollectionView?
    private var index: Int?
    
    
    // USED FOR ANIMATION
    // The initialFrame variable is used to store the frame of cell before animation
    private var initialFrame: CGRect?
    // state is used to track if the cell is expanded or collapsed.
    private var state: State = .collapsed
    
    // the animator variable is used to drive and control the animation.
    private lazy var animator: UIViewPropertyAnimator = {
        let cubicTiming = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.17, y: 0.67), controlPoint2: CGPoint(x: 0.76, y: 1.0))
        //let springTiming = UISpringTimingParameters(mass: 1.0, stiffness: 2.0, damping: 0.2, initialVelocity: .zero)
        
        return UIViewPropertyAnimator(duration: 0.3, timingParameters: cubicTiming)
    }()
    
    private let popupOffset: CGFloat = (UIScreen.main.bounds.height) / 2.0
    private lazy var recognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(popupViewPanned))
        return gesture
    }()
    
    private var animationProgress: CGFloat = 0
    
    
    override func awakeFromNib() {
        self.addGestureRecognizer(recognizer)
    }
    
    func configure(with city: City, collectionView: UICollectionView, index: Int) {
        cityTitle.text = city.name
        cityImage.image = UIImage(named: city.image)
        descriptionLabel.text = city.description
        
        self.collectionView = collectionView
        self.index = index
    }
    
    @IBAction func close(_ sender: Any) {
        toggle()
    }
    
    
    
    func toggle() {
        switch state {
        case .collapsed:
            expand()
        
        case .expanded:
            collapse()
        }
    }
    
    func expand() {
        guard let collectionView = collectionView, let index = index else { return }
        
        animator.addAnimations {
            self.initialFrame = self.frame
            
            self.closeButton.alpha = 1
            self.descriptionLabel.alpha = 1
            self.layer.cornerRadius = 0
            self.frame = CGRect(x: collectionView.contentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x -= 50
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x += 50
            }
            
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { (position) in
            switch position {
            case .end :
                self.state = self.state.change
                self.collectionView?.isScrollEnabled = false
                self.collectionView?.allowsSelection = false
                
            default:
                print("default")
            }
            
        }
        
        animator.startAnimation()
        
    }
    
    func collapse() {
        guard let collectionView = collectionView, let index = index else { return }
        
        animator.addAnimations {
            
            self.descriptionLabel.alpha = 0
            self.closeButton.alpha = 0
            
            self.layer.cornerRadius = self.cornerRadius
            self.frame = self.initialFrame!
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x += 50
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x -= 50
            }
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                collectionView.isScrollEnabled = true
                collectionView.allowsSelection = true
            default:
                print("Default")
            }
        }
        
        animator.startAnimation()
    }
    
    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            toggle()
            animationProgress = animator.fractionComplete
            animator.pauseAnimation()
            
        case .changed:
            let translation = recognizer.translation(in: collectionView)
            var fraction = -translation.y / popupOffset
            if state == .expanded {
                fraction *= -1
            }
            
            if animator.isReversed {
                fraction *= -1
            }
            
            // The completion percentage of the animation.
            animator.fractionComplete = fraction + animationProgress
            
        case .ended:
            let velocity = recognizer.velocity(in: self)
            let shouldComplete = velocity.y > 0
            
            if velocity.y == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            
            switch state {
            case .expanded:
                if !shouldComplete && !animator.isReversed {
                    animator.isReversed = !animator.isReversed
                }
                if shouldComplete && animator.isReversed {
                    animator.isReversed = !animator.isReversed
                }
                
            case .collapsed:
                if shouldComplete && !animator.isReversed {
                    animator.isReversed = !animator.isReversed
                }
                if !shouldComplete && animator.isReversed {
                    animator.isReversed = !animator.isReversed
                }
            }
            
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        default:
            print("Default")
        }
    }
}

extension CityCollectionViewCell {
    // This method controls whether the gesture recognizer should proceed with interpreting touches.
    // If you return false in the method, the gesture recognizer will then ignore the touches.
    // So what we’re going to do is to instruct our own pan recognizer to ignore horizontal swipes.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs(recognizer.velocity(in: recognizer.view).y) > abs(recognizer.velocity(in: recognizer.view).x)
    }
}
