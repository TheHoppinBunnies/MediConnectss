//
//  VideoCallView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import UIKit

struct VideoCallView: View {
    let isAI: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var elapsedTime = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // Video background - in a real app this would be the video feed
            Color.black
                .edgesIgnoringSafeArea(.all)

            // Remote video placeholder
            VStack {
                if isAI {
                    Image(systemName: "brain")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    Text("AI Consultation")
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    Text("Dr. Sarah Johnson")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }

            // Self view (picture-in-picture)
            VStack {
                HStack {
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: 100, height: 150)

                        if isCameraOff {
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        } else {
                            Dumb()
                        }
                    }
                    .padding()
                }

                Spacer()
            }

            // Call controls
            VStack {
                Spacer()

                // Timer
                Text(timeString(from: elapsedTime))
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.bottom)

                // Control buttons
                HStack(spacing: 30) {
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        // End call
                        timer?.invalidate()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        isCameraOff.toggle()
                    }) {
                        Image(systemName: isCameraOff ? "video.slash.fill" : "video.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

import SwiftUI
import AVFoundation

// Camera View using AVFoundation
struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        // This function processes the video frames if needed
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // You can process video frames here if needed.
        }
    }

    var isFrontCamera: Bool // Always use the front camera

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController(isFrontCamera: isFrontCamera)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to update, as the camera is fixed to front-facing mode
    }
}

// Camera view controller responsible for the camera session
class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: CameraView.Coordinator?

    private var currentDevice: AVCaptureDevice?
    private var isFrontCamera: Bool

    init(isFrontCamera: Bool) {
        self.isFrontCamera = isFrontCamera
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
    }

    // Set up the camera with the front camera only
    private func setupCamera() {
        captureSession = AVCaptureSession()

        // Get the front camera (selfie mode)
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        guard !devices.isEmpty else {
            print("No camera found")
            return
        }

        // Select the front-facing camera
        let device = devices.first(where: { $0.position == .front })

        guard let cameraDevice = device else {
            print("No front camera available")
            return
        }

        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                currentDevice = cameraDevice
            } else {
                print("Failed to add camera input")
                return
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }

        // Set up the camera output
        let videoDataOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "sampleBufferQueue"))
        } else {
            print("Failed to add video output")
            return
        }

        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start capturing video
        captureSession.startRunning()

        // Ensure the preview layer is centered within a smaller frame (100x150)
        DispatchQueue.main.async {
            self.centerPreviewLayer()
        }
    }

    // Center the preview layer in a smaller frame (100x150)
    private func centerPreviewLayer() {
        // Get the size and position for the smaller frame (100x150)
        let frameSize = CGSize(width: 100, height: 150)
        let xOffset = (view.bounds.width - frameSize.width) / 2
        let yOffset = (view.bounds.height - frameSize.height) / 2

        // Set the frame for the preview layer (center it in the smaller frame)
        previewLayer.frame = CGRect(x: xOffset, y: yOffset, width: frameSize.width, height: frameSize.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(captureSession.isRunning) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

struct Dumb: View {
    var body: some View {
        CameraView(isFrontCamera: true) // Start with front camera (selfie mode)
            .frame(width: 100, height: 150) // Set the desired frame size
            .cornerRadius(30)
            .shadow(radius: 10)
//            .overlay(
//                Text("Selfie Camera Feed")
//                    .foregroundColor(.white)
//                    .bold()
//                    .padding(5)
//                    .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
//                    .padding(10), alignment: .top
//            )
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}
