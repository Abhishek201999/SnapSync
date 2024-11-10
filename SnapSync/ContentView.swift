//
//  ContentView.swift
//  SnapSync
//
//  Created by Abhishek Singh1 on 09/11/24.
//

import SwiftUI


struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var shouldCapture: Bool = false  // Capture trigger flag

    var body: some View {
        VStack {
            if let capturedImage = capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
                Text("Captured Image Preview")
            } else {
                Text("No Image Captured Yet")
            }
            
            CameraView(onCapture: { imageData in
                if let image = UIImage(data: imageData) {
                    capturedImage = image
                }
            }, shouldCapture: $shouldCapture)  // Pass binding to CameraView
            .frame(height: 400)

            Button("Capture Image") {
                shouldCapture = true  // Set the flag to capture
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    shouldCapture = false // Reset to prevent re-triggering
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ContentView()
}
