//
//  FeedController.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 10/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

typealias PrefetchingDone = (UIImage?, Error?, SDImageCacheType, Bool, URL?) -> Void

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var posts = Posts.sharedInstance.posts
    
    fileprivate var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate let cellId = "cellId"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self

        configureDatabase()
        downloadData()
        
        navigationItem.title = "Teto News"
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts.removeAll()
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("posts").removeObserver(withHandle: refHandle)
        }
    }
    
    fileprivate func downloadData() {
        let url = "gs://teto-feed.appspot.com"
//        let storageRef = FIRStorage.storage().reference(forURL: url)
//        storageRef.downloadURL { (URL, error) -> Void in
//            if (error != nil) {
//                // Handle any errors
//            } else {
//                print(url)
//            }
//        }
    
        let storage = FIRStorage.storage().reference(forURL: url)
        let imageName = "profile-image.png"
        let imageURL = storage.child(imageName)
        
        imageURL.downloadURL { (url, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                }
                
                print(data)
                
                guard let imageData = UIImage(data: data!) else { return }
                
                DispatchQueue.main.async {
//                    print(imageData)
                }
            }).resume()
        }
    }
    
    // Code got from CodeLab Google
    fileprivate func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("posts").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            for _ in snapshot.children {
                let snapshotValue = snapshot.value as? NSDictionary
                if let data = snapshotValue {
                    let post = Post(data: data)
                    strongSelf.posts.append(post)
                }
            }
            
//            print(strongSelf.posts)
            strongSelf.collectionView?.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedCell.post = posts[indexPath.item]
        feedCell.feedController = self
        
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if let statusText = posts[indexPath.item].statusText,
//            let statusImage = posts[indexPath.item].statusImageName {
//            
//            let textWidth = statusText.height(withConstrainedWidth: view.frame.width, font: UIFont.systemFont(ofSize: 14))
//            let imageWidth = statusImage
        
//            let rect = NSString(string: statusText).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
//            
//            let knownHeight: CGFloat = 8 + 44 + 4 + 4 + 200 + 8 + 24 + 8 + 44
//            
//            return CGSize(width: view.frame.width, height: rect.height + knownHeight + 24)
//        }
        
//        if let
    
//        let height = statusImageView?.frame.height + statusTextView.contentSize.height
        
        return CGSize(width: view.frame.width, height: 268)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    let zoomImageView = UIImageView()
    let blackBackgroundView = UIView()
    let navBarCoverView = UIView()
    let tabBarCoverView = UIView()
    
    var statusImageView: UIImageView?
    
    fileprivate func animateImageView(_ statusImageView: UIImageView) {
        self.statusImageView = statusImageView
        
        if let startingFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil) {
            
            statusImageView.alpha = 0
            
            blackBackgroundView.frame = self.view.frame
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            view.addSubview(blackBackgroundView)
            
            navBarCoverView.frame = CGRect(x: 0, y: 0, width: 1000, height: 20 + 44)
            navBarCoverView.backgroundColor = UIColor.black
            navBarCoverView.alpha = 0
            
            
            
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(navBarCoverView)
                
                tabBarCoverView.frame = CGRect(x: 0, y: keyWindow.frame.height - 49, width: 1000, height: 49)
                tabBarCoverView.backgroundColor = UIColor.black
                tabBarCoverView.alpha = 0
                keyWindow.addSubview(tabBarCoverView)
            }
            
            zoomImageView.backgroundColor = UIColor.red
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = statusImageView.image
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            view.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedController.zoomOut)))
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { () -> Void in
                
                let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                
                let y = self.view.frame.height / 2 - height / 2
 
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
                self.blackBackgroundView.alpha = 1
                self.navBarCoverView.alpha = 1
                self.tabBarCoverView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    func zoomOut() {
        if let startingFrame = statusImageView!.superview?.convert(statusImageView!.frame, to: nil) {
            
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.zoomImageView.frame = startingFrame
                
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
                self.tabBarCoverView.alpha = 0
                
            }, completion: { (didComplete) -> Void in
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarCoverView.removeFromSuperview()
                self.tabBarCoverView.removeFromSuperview()
                self.statusImageView?.alpha = 1
            })
            
        }
    }
    
}

class FeedCell: UICollectionViewCell {
    
    var feedController: FeedController?
    
    func animate() {
        feedController?.animateImageView(statusImageView)
    }
    
    var post: Post? {
        didSet {
            
            if let statusText = post?.statusText {
                statusTextView.text = statusText
            }
            
            if let statusImageName = post?.statusImageName {
                statusImageView.sd_setImage(with: URL(string: statusImageName), placeholderImage: UIImage(named: "zuckprofile"))
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(226, green: 228, blue: 232)
        return view
    }()
    
    let shareButton: UIButton = FeedCell.buttonForTitle("Share", imageName: "share")
    
    static func buttonForTitle(_ title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.rgb(143, green: 150, blue: 163), for: UIControlState())
        
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        return button
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(statusTextView)
        addSubview(statusImageView)
        
        statusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedCell.animate as (FeedCell) -> () -> ())))
        
        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: statusTextView)
        addConstraintsWithFormat("H:|[v0]|", views: statusImageView)
        addConstraintsWithFormat("V:|-8-[v0(44)]-4-[v1(200)]-4-|", views: statusTextView, statusImageView)
    }
    
}


