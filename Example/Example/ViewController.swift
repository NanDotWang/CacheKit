//
//  ViewController.swift
//  Example
//
//  Created by Nan Wang on 2017-12-18.
//  Copyright © 2017 NanTech. All rights reserved.
//

import UIKit
import CacheKit

struct Photo {
    let url: URL
    let description: String
}

extension Photo {
    init?(with JSONDictionary: [String: Any]) {
        guard
            let urlString = (JSONDictionary["urls"] as? [String: Any])?["small"] as? String,
            let description = JSONDictionary["description"] as? String
            else { return nil }
        
        self.url = URL(string: urlString)!
        self.description = description
    }
}

struct DataProvider {

    var photos = [Photo]()
    
    func numberOfRows(in section: Int) -> Int {
        return photos.count
    }
    
    func object(for indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func loadCats(completion: @escaping ([Photo]) -> Void) {
        let url = URL(string: "https://api.unsplash.com/collections/861748/photos?client_id=35c6c10b4fa8d6392e5700178bdf30abe8ca1087bf190232c7079f955877f1ae&per_page=30")!
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            switch error {
            case .some(let error):
                print("\(error.localizedDescription)")
            case .none:
                guard
                    let data = data,
                    let photos = ((try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]])?.flatMap({ Photo(with: $0) })
                    else { return }
                
                DispatchQueue.main.async{ completion(photos) }
            }
        }.resume()
    }
}

class ViewController: UIViewController {

    var dataProvider = DataProvider()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        dataProvider.loadCats { [weak self] (photos) in
            self?.dataProvider.photos = photos
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)
        
        let photo = dataProvider.object(for: indexPath)
        cell.textLabel?.text = photo.description
        cell.setImage(with: photo.url)
        //cell.setImage(with: item.imageUrl, placeholder: placeholder)
        //cell.setImage(with: item.imageUrl, placeholder: placeholder, options: [.cacheInMemoryOnly, .forceRefresh])
        return cell
    }
}
