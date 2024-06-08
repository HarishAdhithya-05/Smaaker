import SwiftUI

struct ScannerView: View {
    @State private var scannedCode: String?
    @State private var isScanningComplete = false
    @State private var navigateToNextPage = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("Smaaker logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260.89, height: 273)

                Spacer()

                ZStack {
                    if !isScanningComplete {
                        ScannerViewControllerWrapper(scannedCode: $scannedCode, isScanningComplete: $isScanningComplete)
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipped()
                    }
                }
                .frame(width: 260.89, height: 260.89)
                .cornerRadius(40)
                .padding()

                Text("Scan your QR code")
                    .frame(width: 272, height: 42)

                Spacer()
            }
            .navigationDestination(isPresented: $navigateToNextPage) {
                WelcomeView()
                    .onDisappear {
                        resetScanner()
                    }
            }
            .onChange(of: isScanningComplete) { _, complete in
                if complete {
                    if let scannedCode = scannedCode {
                        let components = parseQRCode(scannedCode)
                        saveToUserDefaults(merchantId: components.merchantId, locationId: components.locationId, outpost: components.outpost)
                        printScannedData()  // Print to console
                    }
                    navigateToNextPage = true
                }
            }
        }
    }

    func parseQRCode(_ code: String) -> (merchantId: String, locationId: String, outpost: String) {
        guard let url = URL(string: code),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return ("", "", "")
        }

        var merchantId = ""
        var locationId = ""
        var outpost = ""

        for queryItem in queryItems {
            switch queryItem.name {
            case "merchantId":
                merchantId = queryItem.value ?? ""
            case "locationId":
                locationId = queryItem.value ?? ""
            case "outpost":
                outpost = queryItem.value ?? ""
            default:
                break
            }
        }

        return (merchantId, locationId, outpost)
    }

    func saveToUserDefaults(merchantId: String, locationId: String, outpost: String) {
        UserDefaults.standard.set(merchantId, forKey: "merchantId")
        UserDefaults.standard.set(locationId, forKey: "locationId")
        UserDefaults.standard.set(outpost, forKey: "outpost")
    }

    func printScannedData() {
        let merchantId = UserDefaults.standard.string(forKey: "merchantId") ?? ""
        let locationId = UserDefaults.standard.string(forKey: "locationId") ?? ""
        let outpost = UserDefaults.standard.string(forKey: "outpost") ?? ""
        print("Merchant ID: \(merchantId)")
        print("Location ID: \(locationId)")
        print("Outpost: \(outpost)")
    }

    func resetScanner() {
        scannedCode = nil
        isScanningComplete = false
    }
}

struct ScannerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isScanningComplete: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // No need to update the view controller as it handles everything internally.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var parent: ScannerViewControllerWrapper

        init(_ parent: ScannerViewControllerWrapper) {
            self.parent = parent
        }

        func didFindCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanningComplete = true
        }
    }
}

// Preview
struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ScannerView()
        }
    }
}
