
import SwiftUI

struct SavedImagesScreen: View {
    let images: [ImageModel]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(images) { image in
                    if let img = image.toUIImage() {
                        Image(uiImage: img)
                            .resizable()
                            .frame(height: 400)
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal,16)
                            .padding(.vertical,10)
                            .overlay(alignment: .bottom) {
                                Text("\(image.uploadStatus)")
                                    .padding(.vertical,10)
                            }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    SavedImagesScreen(images: [])
}
