//
//  CameraView.swift
//  SnapSync
//
//  Created by Abhishek Singh1 on 09/11/24.
//

import Foundation
import AVFoundation
import SwiftUI


struct CameraView: UIViewControllerRepresentable {
    var onCapture: (Data) -> Void
    @Binding var shouldCapture: Bool  // Binding to trigger capture

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        viewController.shouldCapture = $shouldCapture
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation() else { return }
            parent.onCapture(data)
            parent.shouldCapture = false  // Reset capture trigger after photo is taken
        }
    }
}

class CameraViewController: UIViewController {
    var session: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    weak var delegate: CameraView.Coordinator?
    var shouldCapture: Binding<Bool>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        session = AVCaptureSession()
        session?.sessionPreset = .photo
        
        guard let session = session,
              let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)

        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoLayer)
        
        session.startRunning()
    }

    func capturePhoto() {
        guard shouldCapture?.wrappedValue == true else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
    }
}
