
import Foundation
import RealmSwift

class RealmImageModel: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var uri: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var captureDate: Date = Date()
    @objc dynamic var uploadStatus: String = "Pending" // "Pending", "Uploading", "Completed"
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Use a convenience initializer
    convenience init(id: String = UUID().uuidString, uri: String, name: String, captureDate: Date, uploadStatus: String = "Pending") {
        self.init() // Call the base initializer
        self.id = id
        self.uri = uri
        self.name = name
        self.captureDate = captureDate
        self.uploadStatus = uploadStatus
    }
}

extension RealmImageModel {
    func toImageModel() -> ImageModel {
        return ImageModel(id: id, uri: uri, name: name, captureDate: captureDate, uploadStatus: uploadStatus)
    }
}
