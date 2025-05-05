import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    private let storage = Storage.storage()
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "StorageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("preparation_images/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        print("📤 Uploading image to Firebase Storage...")
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error getting download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    let error = NSError(domain: "StorageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])
                    print("❌ \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("✅ Successfully uploaded image: \(downloadURL.absoluteString)")
                completion(.success(downloadURL))
            }
        }
    }
    
    func downloadImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "StorageService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        print("📥 Downloading image from Firebase Storage...")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error downloading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                let error = NSError(domain: "StorageService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                print("❌ \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Successfully downloaded image")
            completion(.success(image))
        }.resume()
    }
} 