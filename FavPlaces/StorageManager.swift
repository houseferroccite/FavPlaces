//
//  StorageManager.swift
//  FavPlaces
//
//  Created by Алексей Зимовец on 19.07.2020.
//  Copyright © 2020 Алексей Зимовец. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager{
    static func saveObject(_ place: Places){
        try! realm.write{
            realm.add(place)
        }
    }
    static func deliteObject(_ place: Places){
        try! realm.write{
            realm.delete(place)
        }
    }
}
