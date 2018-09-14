//
//  LocalImageStore.swift
//  WeRead
//
//  Created by Ian Manor on 13/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import Foundation
import UIKit

class LocalImageStore {
    
    let storageType: StorageType
    
    init(storageType: StorageType) {
        self.storageType = storageType
    }
    
    private var folder: URL {
        return storageType.folder
    }
    
    func save(_ image: UIImage, filename: String) {
        do {
            guard let data = image.pngData() else {
                print("could not save image object")
                return
            }
            
            try data.write(to: folder.appendingPathComponent(filename))
        } catch let e {
            print("ERROR: \(e)")
        }
    }
    
    func retrieve(filename: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: folder.appendingPathComponent(filename).path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: folder.appendingPathComponent(filename))
            return UIImage(data: data)
        } catch let e {
            print("ERROR: \(e)")
            return nil
        }
    }
    
}
