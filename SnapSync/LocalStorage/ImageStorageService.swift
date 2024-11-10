

import Foundation

enum ImageStorageError: Error {
    case saveFailed(String)
    case fetchFailed(String)
    case imageNotFound
    case updateFailed
}

protocol ImageStorageService {
    func saveImageModel(_ imageModel: ImageModel) -> Result<Bool,ImageStorageError>
    func fetchImageModels() -> Result<[ImageModel],ImageStorageError>
    func updateImageStatus(imageID: String, status: String) -> Result<Bool, ImageStorageError>
}
