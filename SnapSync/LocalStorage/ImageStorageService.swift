

import Foundation

enum ImageStorageError: Error {
    case saveFailed(String)
    case fetchFailed(String)
}

protocol ImageStorageService {
    func saveImageModel(_ imageModel: ImageModel) -> Result<Bool,ImageStorageError>
    func fetchImageModels() -> Result<[ImageModel],ImageStorageError>
}
