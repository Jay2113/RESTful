//
//  ViewController.swift
//  RESTful
//
//  Created by Jay Raval on 3/25/19.
//  Copyright © 2019 Jay Raval. All rights reserved.
//

import UIKit

let DomainURL = "https://www.orangevalleycaa.org/api/"

//MARK:- Creator enumeration
enum Creator: String, Codable {
    case ikoliks, bear, others
}

class Music: Codable {
    
    var guid: String?
    var music_url: String?
    var name: String?
    var description: String?
    var dict: [String:Int]?
    var created_by: Creator?
    
    //MARK:- CodingKeys enumeration
    enum CodingKeys: String, CodingKey {
        case guid = "id"
        case music_url, name, description, dict, created_by
    }
    
    //MARK:- Advanced use of encode and decode methods of the Codable Protocol
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let serverGUID = guid?.replacingOccurrences(of: "id:", with: "")
        try container.encode(serverGUID, forKey: .guid)
        try container.encode(name, forKey: .name)
        try container.encode(dict, forKey: .dict)
        // rest of the properties
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let val = try values.decode(String.self, forKey: .guid)
        guid = "id:\(val)"
        name = try values.decode(String.self, forKey: .name)
        dict = try values.decode([String:Int].self, forKey: .dict)
        // rest of the properties
    }
    
    //MARK:- Read request to fetch an object with an ID from the URL
    static func fetch(withID id: Int, completionHandler: @escaping (Music) -> Void) {
        let urlString = DomainURL + "music/id/\(id)"
        
        // Create a URL instance
        if let url = URL.init(string: urlString) {
            
            // Create a data task using URLSession class
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print(String.init(data: data!, encoding: .ascii) ?? "no data")
                
                //Parse the JSON data using JSONSerialization object
                //                if let objectData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                //                    if let dict = objectData as? [String: Any] {
                //                        let newMusic = Music()
                //                        newMusic.id = dict["id"] as? String
                //                        newMusic.name = dict["name"] as? String
                //                        newMusic.description = dict["description"] as? String
                //                        newMusic.music_url = dict["music_url"] as? String
                //                        print(newMusic.music_url)
                //                    }
                //                }
                
                if let newMusic = try? JSONDecoder().decode(Music.self, from: data!) {
                    print(newMusic.music_url ?? "no url")
                    print(newMusic.guid ?? "no guid")
                    completionHandler(newMusic)
                }
                
                
            }
            task.resume()
        }
    }
    
    //MARK:- Read request to fetch multiple objects from the URL
    static func fetchAll(completionHandler: @escaping ([Music]) -> Void) {
        let urlString = DomainURL + "music/)"
        
        // Create a URL instance
        if let url = URL.init(string: urlString) {
            
            // Create a data task using URLSession class
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print(String.init(data: data!, encoding: .ascii) ?? "no data")
                
                if let newMusic = try? JSONDecoder().decode([Music].self, from: data!) {
                    completionHandler(newMusic)
                }
                
                
            }
            task.resume()
        }
    }
    
    //MARK:- POST request to save data to the server
    func saveToServer() {
        let urlString = DomainURL + "music/"
        
        var request = URLRequest(url: URL.init(string: urlString)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(self)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(String.init(data: data!, encoding: .ascii) ?? "no data")
        }
        task.resume()
    }
    
    //MARK:- PUT request to update data on the server
    func updateServer() {
        guard self.guid != nil else { return }
        let urlString = DomainURL + "music/id/\(self.guid!)"
        
        var request = URLRequest(url: URL.init(string: urlString)!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(self)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(String.init(data: data!, encoding: .ascii) ?? "no data")
        }
        task.resume()
    }
    
    //MARK:- DELETE request to delete data on the server
    func deleteFromServer() {
        guard self.guid != nil else { return }
        let urlString = DomainURL + "music/id/\(self.guid!)"
        
        var request = URLRequest(url: URL.init(string: urlString)!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(String.init(data: data!, encoding: .ascii) ?? "no data")
        }
        task.resume()
    }
    
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        Music.fetchAll { (items) in
        //            for item in items {
        //                print(item.name ?? "no name")
        //            }
        //        }
        
        Music.fetch(withID: 1) { (newMusic) in
            print(newMusic.music_url ?? "no url")
            newMusic.description = "new description"
            newMusic.dict = ["key1":99]
            if let musicData =  try? JSONEncoder().encode(newMusic) {
                if let anotherMusic = try? JSONDecoder().decode(Music.self, from: musicData) {
                    print(anotherMusic.dict ?? "no dict")
                }
                print(musicData)
            }
            //            newMusic.saveToServer()
            //            newMusic.updateServer()
            //            newMusic.deleteFromServer()
        }
    }
    
    
}
