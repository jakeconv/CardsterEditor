//
//  FileWriter.swift
//  CardsterEditor
//
//  Created by Jake Convery on 3/26/21.
//

import Foundation

struct FileWriter {
    
    func save(_ data: Data, to url: URL) {
        do {
            try data.write(to: url)
            print("Successfully saved to \(url.absoluteURL)")
        }
        catch {
            print("Error writing file")
        }
    }
    
}
