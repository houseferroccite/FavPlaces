//
//  PlacesModel.swift
//  FavPlaces
//
//  Created by Алексей Зимовец on 15.07.2020.
//  Copyright © 2020 Алексей Зимовец. All rights reserved.
//

import RealmSwift

class Places: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()

    convenience required init(name: String, location:String?, type:String?, imageData:Data?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }

}
