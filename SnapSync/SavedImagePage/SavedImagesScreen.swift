
import SwiftUI

struct SavedImagesScreen: View {
    @ObservedObject var viewModel: SavedImageViewModel
    
    init(imageStorageService: ImageStorageService) {
        self.viewModel = SavedImageViewModel(imageStorageService: imageStorageService)
    }
    
    var body: some View {
        if viewModel.savedImages.isEmpty {
            VStack {
                Text("No images are stored locally")
                    .font(.title)
            }
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.savedImages) { image in
                        if let img = image.toUIImage() {
                            VStack {
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(height: 400)
                                    .frame(maxWidth: .infinity)
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .overlay(alignment: .bottom) {
                                        VStack {
                                            if let progress = viewModel.uploadProgress[image.id] {
                                                ProgressView(value: progress, total: 1.0)
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                            }
                                            Text(image.uploadStatus)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 10)
                                                .background(Color.black.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            
                                            if image.uploadStatus == "failed" {
                                                Button("Retry Upload") {
                                                    viewModel.retryUpload(for: image)
                                                }
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .padding(.top, 8)
                                            }
                                            
                                        }
                                        .padding(.vertical,16)
                                    }
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.uploadPendingImages()
            }
        }
    }
}

