import SwiftUI
import Template

struct ContentView: View {
    @State private var helloWorldResult: String = "Not called yet"
    @State private var echoInput: String = "Hello from Swift!"
    @State private var echoResult: String = "Not called yet"
    @State private var randomResult: String = "Not called yet"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection

                Divider()

                helloWorldSection

                Divider()

                echoSection

                Divider()

                randomSection

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
            Text("Rust Multiplatform Template")
                .font(.title)
                .fontWeight(.bold)

            Text("Demo App")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Testing Rust functions via UniFFI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }

    // MARK: - Hello World Section

    private var helloWorldSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("1. Hello World")
                .font(.headline)

            Text("Tests a simple boolean return from Rust")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: callHelloWorld) {
                Label("Call helloWorld()", systemImage: "globe")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ResultBox(title: "Result", content: helloWorldResult)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Echo Section

    private var echoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("2. Echo")
                .font(.headline)

            Text("Returns the input string, or nil if empty")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("Enter text to echo", text: $echoInput)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 5)

            Button(action: callEcho) {
                Label("Call echo()", systemImage: "arrow.left.arrow.right")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ResultBox(title: "Result", content: echoResult)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Random Section

    private var randomSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("3. Random Number")
                .font(.headline)

            Text("Generates a random number between 0.0 and 1.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: callRandom) {
                Label("Call random()", systemImage: "dice")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            ResultBox(title: "Result", content: randomResult)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Function Calls

    private func callHelloWorld() {
        helloWorldResult = "\(helloWorld())"
    }

    private func callEcho() {
        do {
            let result = try echo(input: echoInput)
            if let text = result {
                echoResult = text
            } else {
                echoResult = "nil (empty input)"
            }
        } catch {
            handleError(error)
            echoResult = "Error occurred: \(error.localizedDescription)"
        }
    }

    private func callRandom() {
        let result = random()
        randomResult = String(format: "%.6f", result)
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

#Preview {
    ContentView()
}
