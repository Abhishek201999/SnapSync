
import SwiftUI
import Combine
import Photos
import AVFoundation

class CameraViewModel: ObservableObject {
	
	@ObservedObject var cameraManager = CameraManager()
	
	@Published var isFlashOn = false
	@Published var showAlertError = false
	@Published var showSettingAlert = false
	@Published var isPermissionGranted: Bool = false
	
    @Published var capturedImage: UIImage? {
        didSet {
            if let image = capturedImage {
                self.images.append(image)
                saveImage(image: image)
            }
        }
    }
    
    var images: [UIImage] = []
	
	var alertError: AlertError!
	var session: AVCaptureSession = .init()
    var imageStorageService: ImageStorageService?
    var hasConfigured = false
	private var cancelables = Set<AnyCancellable>()
	
	init() {
		session = cameraManager.session
        initialiseImageStorage()
	}
    
    func initialiseImageStorage() {
        do {
            imageStorageService = try RealmStorageService()
        } catch {
            print("Realm init failed \(error.localizedDescription)")
        }
    }
    
    private func saveImage(image: UIImage) {
        guard let imageStorageService = imageStorageService else { return }
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            
            // Create the ImageModel
            let newImageModel = ImageModel( uri: fileURL.absoluteString, name: fileName, captureDate: Date() )
            
            let result = imageStorageService.saveImageModel(newImageModel)
            
            print("Image saved successfully and ImageModel created.")
        } catch {
            print("Error saving image: \(error)")
        }
    }
        
    func fetchAllSavedImages() -> [ImageModel] {
        let result = imageStorageService?.fetchImageModels()
        switch result {
        case .success(let data):
            return data
        case .failure(_):
            return []
        case .none:
            return []
        }
    }
	
	deinit {
		cameraManager.stopCapturing()
	}
	
	func setupBindings() {
        hasConfigured = true
		cameraManager.$shouldShowAlertView.sink { [weak self] value in
			self?.alertError = self?.cameraManager.alertError
			self?.showAlertError = value
		}
		.store(in: &cancelables)
		
		cameraManager.$capturedImage.sink { [weak self] image in
			self?.capturedImage = image
		}.store(in: &cancelables)
	}
	
	func requestCameraPermission() {
		AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
			guard let self else { return }
			if isGranted {
				self.configureCamera()
				DispatchQueue.main.async {
					self.isPermissionGranted = true
				}
			}
		}
	}
	
	func configureCamera() {
		checkForDevicePermission()
		cameraManager.configureCaptureSession()
	}
	
	func checkForDevicePermission() {
		let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
		
		DispatchQueue.main.async { [weak self] in
			if videoStatus == .authorized {
				self?.isPermissionGranted = true
			} else if videoStatus == .notDetermined {
				AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in })
			} else if videoStatus == .denied {
				self?.isPermissionGranted = false
				self?.showSettingAlert = true
			}
		}
	}
	
	func switchCamera() {
		cameraManager.position = cameraManager.position == .back ? .front : .back
		cameraManager.switchCamera()
	}
	
	func switchFlash() {
		isFlashOn.toggle()
		cameraManager.toggleTorch(tourchIsOn: isFlashOn)
	}
	
	func zoom(with factor: CGFloat) {
		cameraManager.setZoomScale(factor: factor)
	}
	
	func setFocus(point: CGPoint) {
		cameraManager.setFocusOnTap(devicePoint: point)
	}
	
	func captureImage() {
//		requestGalleryPermission()
//		let permission = checkGalleryPermissionStatus()
//		if permission.rawValue != 2 {
			cameraManager.captureImage()
//		}
	}
	
	func requestGalleryPermission() {
		PHPhotoLibrary.requestAuthorization { status in
			switch status {
			case .authorized:
				break
			case .denied:
				self.showSettingAlert = true
			default:
				break
			}
		}
	}
	
	func checkGalleryPermissionStatus() -> PHAuthorizationStatus {
		return PHPhotoLibrary.authorizationStatus()
	}
}
