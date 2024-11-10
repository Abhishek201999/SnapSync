import Foundation

class ImageUploader: NSObject, URLSessionTaskDelegate {
    var uploadProgress: ((Double) -> Void)?

    func uploadImage(fileURL: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        // Endpoint URL
        let url = URL(string: "https://www.clippr.ai/api/upload")!
        
        // Set up URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create a boundary for multipart/form-data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Generate multipart form body with image data
        let httpBody = createBody(boundary: boundary, fileURL: fileURL, fileName: fileURL.lastPathComponent)
        
        // Configure URLSession with delegate to track progress
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        // Create upload task
        let uploadTask = session.uploadTask(with: request, from: httpBody) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            }
        }
        
        uploadTask.resume()
    }
    
    private func createBody(boundary: String, fileURL: URL, fileName: String) -> Data {
        var body = Data()
        
        // Add image data to the request body
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        
        // Add image file data
        if let imageData = try? Data(contentsOf: fileURL) {
            body.append(imageData)
        }
        
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    // URLSessionTaskDelegate method to track upload progress
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        uploadProgress?(progress)
    }
}

