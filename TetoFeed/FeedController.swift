//
//  FeedController.swift
//  TetoFeed
//
//  Created by Fernando Augusto de Marins on 10/04/17.
//  Copyright © 2017 Fernando Augusto de Marins. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

var imageHeight = 0

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var posts = Posts.sharedInstance.posts
    
    fileprivate var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate let cellId = "cellId"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        navigationItem.title = "Teto News"
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        
        configureDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageHeight = Int(view.frame.width)
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("posts").removeObserver(withHandle: refHandle)
        }
    }
    
    // Code got from CodeLab Google
    fileprivate func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("posts").observe(.childAdded, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            let snapShotValue = snapshot.value as? NSDictionary
            if let data = snapShotValue {
                let post = Post(data: data)
                strongSelf.posts.append(post)
            }
            
            strongSelf.collectionView?.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func gradient(frame: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.locations = [0.0, 0.5, 1.0]
        layer.colors = [UIColor.clear.cgColor, UIColor.rgb(127, green: 127, blue: 127, alpha: 1), UIColor.black.cgColor]
        layer.opacity = 0.6
        return layer
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.insertSublayer(gradient(frame: cell.bounds), at: 4)
        cell.backgroundColor = UIColor.clear
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedCell.post = posts[indexPath.item]
        feedCell.feedController = self
        
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailController()
        vc.post = posts[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}

class FeedCell: UICollectionViewCell {
    
    var feedController: FeedController?

    var post: Post? {
        didSet {
            
            if let familyName = post?.familyName {
                self.familyName.text = familyName
            }
            
            if let familyText = post?.familyText {
                
                // Cut the text to have a better interface
                if familyText.characters.count > 160 {
                    let index = familyText.index(familyText.startIndex, offsetBy: 160)
                    let text = familyText.substring(to: index)
                    self.familyText.text = text + "..."
                } else {
                    self.familyText.text = familyText
                }

            }
            
            if let familyImage = post?.familyImage {
                self.familyImage.sd_setImage(with: URL(string: familyImage), placeholderImage: UIImage(named: "placeholder"))
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
    
    let familyName: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Roboto-Regular", size: 30)
        textView.textColor = UIColor.rgb(255, green: 255, blue: 255, alpha: 0.9)
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let familyText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Roboto-Regular", size: 12)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.rgb(255, green: 255, blue: 255, alpha: 0.9)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textContainer.maximumNumberOfLines = 3
        return textView
    }()
    
    let familyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(226, green: 228, blue: 232, alpha: 1)
        return view
    }()
    
    let shareButton: UIButton = FeedCell.buttonForTitle("Share", imageName: "share")
    
    static func buttonForTitle(_ title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.rgb(143, green: 150, blue: 163, alpha: 1), for: UIControlState())
        
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        return button
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(familyName)
        addSubview(familyText)
        addSubview(familyImage)
        
        // Setting the text on top of the image
        familyName.layer.zPosition = 3
        familyText.layer.zPosition = 4
        
        familyImage.setShowActivityIndicator(true)
        familyImage.setIndicatorStyle(.gray)

        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: familyName)
        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: familyText)
        addConstraintsWithFormat("H:|[v0]|", views: familyImage)
        
        addConstraintsWithFormat("V:|-180-[v0]-8-[v1]-4-|", views: familyName, familyText)
        addConstraintsWithFormat("V:|[v0(\(imageHeight))]|", views: familyImage)

    }
    
}


