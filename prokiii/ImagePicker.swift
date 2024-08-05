//
//  ImagePicker.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-27.
//

import SwiftUI
import PhotosUI

// SwiftUI view that wraps a PHPickerViewController for image picking
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage? // Binding to the selected image
    var onImagePicked: ((UIImage) -> Void)? = nil 

    // Creates the PHPickerViewController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // Configure the picker to show images only
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator // Set the delegate to the coordinator
        return picker
    }

    // Updates the PHPickerViewController
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Creates the coordinator for handling PHPickerViewControllerDelegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onImagePicked: onImagePicked)
    }

    // Coordinator class to act as PHPickerViewControllerDelegate
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker // Reference to the parent ImagePicker
        var onImagePicked: ((UIImage) -> Void)? // Optional callback when an image is picked

        init(_ parent: ImagePicker, onImagePicked: ((UIImage) -> Void)? = nil) {
            self.parent = parent
            self.onImagePicked = onImagePicked
        }

        // Delegate method called when the user finishes picking an image
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) // Dismiss the picker

            guard let provider = results.first?.itemProvider else { return } // Get the first result's item provider

            // Check if the provider can load a UIImage
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        self.parent.image = image // Set the selected image
                        self.onImagePicked?(image) // Call the optional callback
                    }
                }
            }
        }
    }
}

