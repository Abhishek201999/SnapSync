
import Foundation
import UserNotifications

class SavedImageViewModel: ObservableObject {
    let imageStorageService: ImageStorageService
    
    @Published var savedImages: [ImageModel] = []
    @Published var uploadProgress: [String: Double] = [:]
    
    init(imageStorageService: ImageStorageService) {
        self.imageStorageService = imageStorageService
        fetchAllSavedImages()
    }
    
    func fetchAllSavedImages() {
        let result = imageStorageService.fetchImageModels()
        switch result {
        case .success(let data):
            self.savedImages = data
        case .failure(_):
            self.savedImages = []
        }
    }
    
    func uploadPendingImages() {
        for image in savedImages where image.uploadStatus == "pending" {
            uploadImage(image)
        }
    }
    
    func retryUpload(for image: ImageModel) {
        uploadImage(image)
    }
    
    private func uploadImage(_ image: ImageModel) {
        let fileURL = URL(string: image.uri)
        
        // Set the status to "uploading"
        if let index = savedImages.firstIndex(where: { $0.id == image.id }) {
            savedImages[index].uploadStatus = "uploading"
        }
        
        let uploader = ImageUploader()
        uploader.uploadProgress = { [weak self] progress in
            DispatchQueue.main.async {
                self?.uploadProgress[image.id] = progress
            }
        }
        if let fileUrl = fileURL {
            
            uploader.uploadImage(fileURL: fileUrl) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.markImageAsUploaded(image)
                        self?.showLocalNotification(for: image)
                    case .failure(let error):
                        print("Failed to upload image \(image.id): \(error)")
                        self?.markImageAsFailed(image)
                    }
                }
            }
        }
    }
    
    private func markImageAsUploaded(_ image: ImageModel) {
        if let index = savedImages.firstIndex(where: { $0.id == image.id }) {
            savedImages[index].uploadStatus = "uploaded"
            uploadProgress[image.id] = nil
            
            // Update the status in the database
            _ = imageStorageService.updateImageStatus(imageID: image.id, status: "uploaded")
        }
    }
    
    private func markImageAsFailed(_ image: ImageModel) {
        if let index = savedImages.firstIndex(where: { $0.id == image.id }) {
            savedImages[index].uploadStatus = "failed"
            uploadProgress[image.id] = nil
            
            // Update the status in the database
            _ = imageStorageService.updateImageStatus(imageID: image.id, status: "failed")
        }
    }
        
    private func showLocalNotification(for image: ImageModel) {
        let content = UNMutableNotificationContent()
        content.title = "Image Upload Complete"
        content.body = "The image with ID \(image.id) has been uploaded successfully."
        content.sound = .default
        
        // Create a trigger for the notification (e.g., fire immediately)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (3), repeats: false)
        
        // Create a request for the notification
        let request = UNNotificationRequest(identifier: "imageUploadNotification_\(image.id)", content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
