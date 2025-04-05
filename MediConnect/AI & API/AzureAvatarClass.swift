import SwiftUI
import AVKit

class AvatarSynthesisService: ObservableObject {
    // Configure with your Flask API URL
    private let apiBaseURL = "http://10.2.17.120:4000"

    @Published var isLoading = false
    @Published var statusMessage = "Ready"
    @Published var jobId: String?
    @Published var downloadUrl: String?
    @Published var errorMessage: String?

    // Submit a new synthesis job
    func submitJob(text: String, voice: String = "en-US-AndrewMultilingualNeural",
                  character: String = "Lisa", style: String = "casual-sitting") {

        isLoading = true
        statusMessage = "Submitting job..."
        errorMessage = nil

        guard let url = URL(string: "\(apiBaseURL)/submit") else {
            handleError("Invalid API URL")
            return
        }

        let payload: [String: Any] = [
            "text": text,
            "voice": voice,
            "character": character,
            "style": style
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            handleError("Failed to encode request: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.handleError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self.handleError("No data received")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            if let jobId = json["job_id"] as? String {
                                self.jobId = jobId
                                self.statusMessage = "Job submitted successfully"
                                self.startPolling(jobId: jobId)
                            } else {
                                self.handleError("No job ID in response")
                            }
                        } else if let errorMsg = json["error"] as? String {
                            self.handleError("API error: \(errorMsg)")
                        } else {
                            self.handleError("Unknown API response")
                        }
                    }
                } catch {
                    self.handleError("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    // Check status of a job
    func checkStatus(jobId: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "\(apiBaseURL)/status/\(jobId)") else {
            handleError("Invalid status URL")
            completion?(false)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.handleError("Status check failed: \(error.localizedDescription)")
                    completion?(false)
                    return
                }

                guard let data = data else {
                    self.handleError("No data received from status check")
                    completion?(false)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let status = json["status"] as? String {
                            self.statusMessage = "Status: \(status)"

                            if status == "Succeeded" {
                                if let outputs = json["outputs"] as? [String: Any],
                                   let resultUrl = outputs["result"] as? String {
                                    self.downloadUrl = resultUrl
                                    self.statusMessage = "Completed successfully"
                                    completion?(true)
                                    return
                                }
                            } else if status == "Failed" {
                                self.statusMessage = "Job failed"
                                completion?(false)
                                return
                            }

                            // Still in progress
                            completion?(false)
                        } else {
                            self.handleError("Invalid status response")
                            completion?(false)
                        }
                    }
                } catch {
                    self.handleError("Failed to decode status: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }.resume()
    }

    // Poll for status updates
    private func startPolling(jobId: String) {
        self.statusMessage = "Processing..."

        func poll() {
            self.checkStatus(jobId: jobId) { stillRunning in
                if !stillRunning && self.downloadUrl == nil {
                    // If not complete and no errors, continue polling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        poll()
                    }
                }
            }
        }

        // Start polling
        poll()
    }

    private func handleError(_ message: String) {
        self.isLoading = false
        self.errorMessage = message
        self.statusMessage = "Error occurred"
        print("Error: \(message)")
    }
}

