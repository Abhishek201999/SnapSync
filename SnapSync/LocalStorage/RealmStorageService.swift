
import Foundation
import RealmSwift

class RealmStorageService: ImageStorageService {
    
//    static let shared: RealmStorageService = {
//        do {
//            return try RealmStorageService()
//        } catch {
//            fatalError("Failed to initialize Realm: \(error)")
//        }
//    }()
    
    private var realm: Realm
    
    init() throws {
        do {
            self.realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
            throw ImageStorageError.saveFailed("Realm initialization failed")
        }
    }
    
    func saveImageModel(_ imageModel: ImageModel) -> Result<Bool,ImageStorageError> {
        do {
            try realm.write {
                realm.add(imageModel.toRealImageModel())
            }
            return .success(true)
        } catch {
            print("Error saving image model to Realm: \(error)")
            return .failure(ImageStorageError.saveFailed("Failed to save model in realm"))
        }
    }
    
    func fetchImageModels() -> Result<[ImageModel],ImageStorageError> {
        let realImageModels = realm.objects(RealmImageModel.self)
        let imageModels = realImageModels.map{$0.toImageModel()}
        return .success(Array(imageModels))
    }
}
