//
//  RNNotificationView.swift
//
//  Created by Romilson Nunes on 21/10/16.
//
//

import UIKit

open class RNNotificationView: UIToolbar {
    
    // MARK: - Properties
    
    public static var sharedNotification = RNNotificationView()

    open var titleFont = RNNotification.titleFont {
        didSet {
            titleLabel.font = titleFont
        }
    }
    open var titleTextColor = UIColor.white {
        didSet {
            titleLabel.textColor = titleTextColor
        }
    }
    open var subtitleFont = RNNotification.subtitleFont {
        didSet {
            subtitleLabel.font = subtitleFont
        }
    }
    open var subtitleTextColor = UIColor.white {
        didSet {
            subtitleLabel.textColor = subtitleTextColor
        }
    }
    open var duration: TimeInterval = RNNotification.exhibitionDuration
    
    open fileprivate(set) var isAnimating = false
    open fileprivate(set) var isDragging = false
    
    fileprivate var dismissTimer: Timer? {
        didSet {
            if oldValue?.isValid == true {
                oldValue?.invalidate()
            }
        }
    }
    
    fileprivate var tapAction: (() -> ())?

   
    /// Views
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 3
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    fileprivate lazy var titleLabel: UILabel = { [unowned self] in
        let titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.font = self.titleFont
        titleLabel.textColor = self.titleTextColor
        return titleLabel
        }()
    fileprivate lazy var subtitleLabel: UILabel = { [unowned self] in
        let subtitleLabel = UILabel()
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = self.subtitleFont
        subtitleLabel.textColor = self.subtitleTextColor
        return subtitleLabel
        }()
    
    fileprivate lazy var dragView: UIView = { [unowned self] in
        let dragView = UIView()
        dragView.backgroundColor = UIColor(white: 1.0, alpha: 0.35)
        dragView.layer.cornerRadius = RNNotificationLayout.dragViewHeight / 2
        return dragView
        }()
    
    
    /// Frames
    
    open var  iconSize: CGSize = RNNotificationLayout.iconSize {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    fileprivate var imageViewFrame: CGRect {
        return CGRect(x: 15.0, y: 8.0 + RNNotificationLayout.contentTop, width: iconSize.width, height: iconSize.height)
    }
    
    fileprivate var dragViewFrame: CGRect {
        let width: CGFloat = 40
        return CGRect(x: (RNNotificationLayout.width - width) / 2 ,
                      y: RNNotificationLayout.height - 5,
                      width: width,
                      height: RNNotificationLayout.dragViewHeight)
    }
    

    fileprivate var textPointX: CGFloat {
        return  RNNotificationLayout.imageBorder + self.iconSize.width + RNNotificationLayout.textBorder
    }
    
    /// The origin of the text
    fileprivate var titleLabelFrame: CGRect {
        let y: CGFloat = 3 + RNNotificationLayout.contentTop
        if self.imageView.image == nil {
            let x: CGFloat = 5
            return CGRect(x: x, y: y, width: RNNotificationLayout.width - x, height: RNNotificationLayout.labelTitleHeight)
        }
        return CGRect(x: textPointX, y: y, width: RNNotificationLayout.width - textPointX, height: RNNotificationLayout.labelTitleHeight)
    }
    
    fileprivate var messageLabelFrame: CGRect {
        let y: CGFloat = 25 + RNNotificationLayout.contentTop
        if self.imageView.image == nil {
            let x: CGFloat = 5
            return CGRect(x: x, y: y, width: RNNotificationLayout.width - x, height: RNNotificationLayout.labelMessageHeight)
        }
        return CGRect(x: textPointX, y: y, width: RNNotificationLayout.width - textPointX, height: RNNotificationLayout.labelMessageHeight)
    }
   
    // MARK: - Initialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: RNNotificationLayout.width, height: RNNotificationLayout.height))
        
        startNotificationObservers()
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override Toolbar
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupFrames()
    }
    
    open override var intrinsicContentSize : CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: RNNotificationLayout.height)
    }
    
    
    // MARK: - Observers
    
    fileprivate func startNotificationObservers() {
        /// Enable orientation tracking
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        /// Add Orientation notification
        NotificationCenter.default.addObserver(self, selector: #selector(RNNotificationView.orientationStatusDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    
    // MARK: - Orientation Observer
    
    @objc fileprivate func orientationStatusDidChange(_ notification: Foundation.Notification) {
        setupUI()
    }
    
    
    // MARK: - Setups
    
    // TODO: - Use autolayout
    fileprivate func setupFrames() {
        
        var frame = self.frame
        frame.size.width = RNNotificationLayout.width
        self.frame = frame
        
        self.titleLabel.frame = self.titleLabelFrame
        self.imageView.frame = self.imageViewFrame
        self.subtitleLabel.frame = self.messageLabelFrame
        self.dragView.frame = self.dragViewFrame

        fixLabelMessageSize()
    }

    fileprivate func setupUI() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Bar style
        self.barTintColor = nil
        self.isTranslucent = true
        self.barStyle = UIBarStyle.black
        
        self.tintColor = UIColor(red: 5, green: 31, blue: 75, alpha: 1)
        
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude - 1
        self.backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
        self.isExclusiveTouch = true
        
        self.frame = CGRect(x: 0, y: 0, width: RNNotificationLayout.width, height: RNNotificationLayout.height)
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleLeftMargin]
        
        // Add subviews
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.imageView)
        self.addSubview(self.dragView)
        
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(RNNotificationView.didTap(_:)))
        self.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(RNNotificationView.didPan(_:)))
        self.addGestureRecognizer(pan)
        
        // Setup frames
        self.setupFrames()
    }
    
    
    // MARK: - Helper
    
    fileprivate func fixLabelMessageSize() {
        let size = self.subtitleLabel.sizeThatFits(CGSize(width: RNNotificationLayout.width - self.textPointX, height: CGFloat.greatestFiniteMagnitude))
        var frame = self.subtitleLabel.frame
        frame.size.height = size.height > RNNotificationLayout.labelMessageHeight ? RNNotificationLayout.labelMessageHeight : size.height
        self.subtitleLabel.frame = frame;
    }
    
    
    // MARK: - Actions
    
    @objc fileprivate func scheduledDismiss() {
        self.hide(completion: nil)
    }
    
    
    // MARK: - Tap gestures
    
    @objc fileprivate func didTap(_ gesture: UIGestureRecognizer) {
        self.isUserInteractionEnabled = false
        self.tapAction?()
        self.hide(completion: nil)
    }

    @objc fileprivate func didPan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .ended:
            self.isDragging = false
            if frame.origin.y < 0 || self.duration <= 0 {
                self.hide(completion: nil)
            }
            
        case .began:
            self.isDragging = true

        case .changed:
            guard let superview = self.superview else {
                return
            }
            
            guard let gestureView = gesture.view else {
                return
            }
            
            let translation = gesture.translation(in: superview)
            // Figure out where the user is trying to drag the view.
            let newCenter = CGPoint(x: superview.bounds.size.width / 2,
                                    y: gestureView.center.y + translation.y)
            
            // See if the new position is in bounds.
            if (newCenter.y >= (-1 * RNNotificationLayout.height / 2) && newCenter.y <= RNNotificationLayout.height / 2) {
                gestureView.center = newCenter
                gesture.setTranslation(CGPoint.zero, in: superview)
            }

        default:
            break
        }
        
    }
}



public extension RNNotificationView {
    
    // MARK: - Public Methods
    
    func show(withImage image: UIImage?, title: String?, message: String?, duration: TimeInterval = RNNotification.exhibitionDuration, iconSize: CGSize = RNNotificationLayout.iconSize, onTap: (() -> ())?) {
        
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        /// Invalidate dismissTimer
        self.dismissTimer = nil
        
        self.tapAction = onTap
        self.duration = duration
        
        /// Content
        self.imageView.image = image
        self.titleLabel.text = title
        self.subtitleLabel.text = message
        
        self.iconSize = iconSize
        
        /// Prepare frame
        var frame = self.frame
        frame.origin.y = -frame.size.height
        self.frame = frame
        
        self.setupFrames()
        
        self.isUserInteractionEnabled = true
        self.isAnimating = true
        
        /// Add to window
        if #available(iOS 11.0, *), let top =
            UIApplication.shared.delegate?.window??.safeAreaInsets.top, top > 0 {
            // iPhone X
            window?.windowLevel = UIWindow.Level.normal
        } else {
            window?.windowLevel = UIWindow.Level.statusBar
        }
        window?.addSubview(self)
        
        /// Show animation
        UIView.animate(withDuration: RNNotification.animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {

            var frame = self.frame
            frame.origin.y += frame.size.height
            self.frame = frame

        }) { (finished) in
            self.isAnimating = false
        }
        
        // Schedule to hide
        if self.duration > 0 {
            let time = self.duration + RNNotification.animationDuration
            self.dismissTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(RNNotificationView.scheduledDismiss), userInfo: nil, repeats: false)
        }
        
    }
    
    func hide(completion: (() -> ())?) {
        
        guard !self.isDragging else {
            self.dismissTimer = nil
            return
        }
        
        if self.superview == nil {
            isAnimating = false
            return
        }
        
        // Case are in animation of the hide
        if (isAnimating) {
            return
        }
        isAnimating = true
        
        // Invalidate timer auto close
        self.dismissTimer = nil
        
        /// Show animation
        UIView.animate(withDuration: RNNotification.animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            var frame = self.frame
            frame.origin.y -= frame.size.height
            self.frame = frame
            
        }) { (finished) in
            self.removeFromSuperview()
            UIApplication.shared.delegate?.window??.windowLevel = UIWindow.Level.normal
            
            self.isAnimating = false
            completion?()
        }
    }

    
    // MARK: - Helpers
    
    static func show(withImage image: UIImage?, title: String?, message: String?, duration: TimeInterval = RNNotification.exhibitionDuration, iconSize: CGSize = RNNotificationLayout.iconSize, onTap: (() -> ())? = nil) {
        self.sharedNotification.show(withImage: image, title: title, message: message, duration: duration, iconSize: iconSize, onTap: onTap)
    }
    
    static func hide(completion: (() -> ())? = nil) {
        self.sharedNotification.hide(completion: completion)
    }

}
