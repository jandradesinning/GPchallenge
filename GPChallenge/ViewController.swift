//
//  ViewController.swift
//  GPChallenge
//
//  Created by Felipe Sinning on 3/23/19.
//  Copyright © 2019 Felipe Sinning. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableVIew: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    let albumCellId = "albumCellId"
    
    var artistsArray: [String] = []
    
    var AlbumsArray: [String] = []
    
    var artisArtworkArray: [UIImage] = []
    
    let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/20/explicit.json")

    var newResizedImage: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Serialize to JSON
        let jsonData = loadJSON(fileURL: url!)
        let json = JSON(jsonData!)
        
        // Getting an array of string from a JSON Array
        let arrayOfString = json["feed"]["results"].arrayValue.map({$0["artistName"]})
        let arrayOfSongNames = json["feed"]["results"].arrayValue.map({$0["name"]})
        let artworkURL = json["feed"]["results"].arrayValue.map({$0["artworkUrl100"]})
        
        for obj in arrayOfString {
            //    print(obj.stringValue)
            artistsArray.append(obj.stringValue)
        }
        
        for obj in arrayOfSongNames {
            //    print(obj.stringValue)
            AlbumsArray.append(obj.stringValue)
        }
        
        for obj in artworkURL{
            
            newResizedImage = UIImage(url: URL(string: obj.stringValue))!
            
            newResizedImage = resizeImage(image: newResizedImage, targetSize: CGSize.init(width: 40, height: 40))
            
            artisArtworkArray.append(newResizedImage)
            
        }
        
        setupViews()
        setupTableView()
        
    }

    func setupViews() {
        navigationItem.title = "Apple Music"
        navigationController?.navigationBar.barTintColor = UIColor(r: 0, g: 100, b: 198)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                   NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
    }
    
    func setupTableView() {
        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.register(AlbumCell.self, forCellReuseIdentifier: albumCellId)
        
        view.addSubview(tableVIew)
        tableVIew.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return AlbumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellId, for: indexPath) as! AlbumCell
        cell.pictureImageView.image = artisArtworkArray[indexPath.item]
        cell.titleLabel.text = AlbumsArray[indexPath.item] + " - " + artistsArray[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //if section == 1 {
        //    return "Top Artists"
        //}
        return "Albums - Coming Soon"
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func loadJSON(fileURL:URL)->[String : Any]? {
        // Parse the JSON
        do {
            // Create a string out of the file contents
            let contents = try String(contentsOf: fileURL) // use contentsOfFile for strings
            // Turn it into data to feed JSONSerialization class
            let data     = contents.data(using: String.Encoding.utf8)
            // Attempt to turn it into JSON, or show error
            let json:[String:Any]? = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
            
            return json
            
        } catch {
            Swift.print("Error parsing json")
            return nil
        }
    }

    
}

class AlbumCell: UITableViewCell {
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.setCellShadow()
        return view
    }()
    
    let pictureImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor(r: 245, g: 245, b: 245)
        addSubview(cellView)
        cellView.addSubview(pictureImageView)
        cellView.addSubview(titleLabel)
        
        cellView.setAnchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8)
        
        pictureImageView.setAnchor(top: nil, left: cellView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        pictureImageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        
        titleLabel.setAnchor(top: nil, left: pictureImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 40)
        titleLabel.centerYAnchor.constraint(equalTo: pictureImageView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}
