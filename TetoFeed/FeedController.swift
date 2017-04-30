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
            
            strongSelf.collectionView?.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func gradient(frame:CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
//        layer.startPoint = CGPoint(x: 0, y: 0.5)
//        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.locations = [0.0, 1.0]
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        return layer
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.insertSublayer(gradient(frame: cell.bounds), at:0)
        cell.backgroundColor = UIColor.clear
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedCell.post = posts[indexPath.item]
        feedCell.feedController = self
        
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.frame.width, height: 268)
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
                self.familyText.text = familyText
            }
            
            if let familyImage = post?.familyImage {
                print(self.familyImage)
                self.familyImage.sd_setImage(with: URL(string: familyImage), placeholderImage: UIImage(named: "fernando"))
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
        textView.textColor = UIColor.white
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let familyText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Roboto-Regular", size: 12)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let familyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        
        addSubview(familyName)
        addSubview(familyText)
        addSubview(familyImage)
        bringSubview(toFront: familyText)
        bringSubview(toFront: familyName)

        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: familyName)
        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: familyText)
        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: familyImage)
        
        addConstraintsWithFormat("V:|-160-[v0(44)]-8-[v1]-4-|", views: familyName, familyText)
        addConstraintsWithFormat("V:|-4-[v0(264)]-4-|", views: familyImage)

    }
    
}


