
import Foundation
import RealmSwift
import SwiftUI

class ImageModel: Identifiable {
    var id: String
    var uri: String = ""
    var name: String = ""
    var captureDate: Date = Date()
    var uploadStatus: String
    
    init(id: String = UUID().uuidString, uri: String, name: String, captureDate: Date, uploadStatus: String="pending") {
        self.id = id
        self.uri = uri
        self.name = name
        self.captureDate = captureDate
        self.uploadStatus = uploadStatus
    }
}

extension ImageModel {
    func toRealImageModel() -> RealmImageModel {
        return RealmImageModel(id: id, uri: uri, name: name, captureDate: captureDate, uploadStatus: uploadStatus)
    }
    
    func toUIImage() -> UIImage? {
        guard let fileURL = URL(string: uri) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
}
