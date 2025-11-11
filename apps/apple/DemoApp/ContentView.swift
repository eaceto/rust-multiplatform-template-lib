import SwiftUI
import Template

struct ContentView: View {
    @State private var backendInfoResult: String = "Not called yet"
    @State private var modelMetadataResult: String = "Not called yet"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection

                Divider()

                backendInfoSection

                Divider()

                modelMetadataSection

                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Rust LLM Library")
                .font(.title)
                .fontWeight(.bold)

            Text("Demo App")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Powered by Candle")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }

    // MARK: - Backend Info Section

    private var backendInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Backend Detection")
                .font(.headline)

            Text("Detects available compute backends (Metal, CPU, etc.)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: callGetBackendInfo) {
                Label("Get Backend Info", systemImage: "cpu")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ResultBox(title: "Result", content: backendInfoResult)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Model Metadata Section

    private var modelMetadataSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Model Metadata")
                .font(.headline)

            Text("Loads metadata from the bundled test GGUF file")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: callLoadModelMetadata) {
                Label("Load Test Model", systemImage: "doc.text")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ResultBox(title: "Result", content: modelMetadataResult)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Function Calls

    private func callGetBackendInfo() {
        do {
            backendInfoResult = try getBackendInfo()
        } catch {
            handleError(error)
            backendInfoResult = "Error: \(error.localizedDescription)"
        }
    }

    private func callLoadModelMetadata() {
        do {
            // Get the path to the bundled test GGUF file
            guard let modelPath = Bundle.main.path(forResource: "tinyllama-test", ofType: "gguf") else {
                modelMetadataResult = "Error: Test model file not found in bundle"
                return
            }

            let metadata = try loadModelMetadata(modelPath: modelPath)

            modelMetadataResult = """
            Model Type: \(metadata.modelType)
            Vocab Size: \(metadata.vocabSize)
            Context Length: \(metadata.contextLength)
            Embedding Dimensions: \(metadata.embeddingDimensions)
            Parameter Count: \(metadata.parameterCount)
            File Size: \(formatBytes(metadata.fileSizeBytes))
            """
        } catch {
            handleError(error)
            modelMetadataResult = "Error: \(error.localizedDescription)"
        }
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

#Preview {
    ContentView()
}
