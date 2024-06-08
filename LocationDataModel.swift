import SwiftUI
import AVFoundation
import Combine
// Location Data Model
struct LocationData: Codable {
    let status: Bool
    let location: LocationDetails
}

struct LocationDetails: Codable {
    let createdAt: String
    let locationDetail: LocationDetail
    let locationId: String
    let smaakerMerchantId: String
    let nickName: String
    let status: String
}

struct LocationDetail: Codable {
    let country: String
    let address: Address
    let capabilities: [String]
    let timezone: String
    let businessName: String
    let description: String
    let languageCode: String
    let type: String
    let logoUrl: String
    let merchantId: String
    let name: String
    let logo: String
    let currency: String
}

struct Address: Codable {
    let locality: String
    let addressLine1: String
    let addressLine2: String
    let postalCode: String
    let country: String
}

// Location View Model
class LocationViewModel: ObservableObject {
    @Published var location: LocationDetails?
    @Published var isLoading = false

    func fetchLocationDetails(outpost: String) {
        guard var urlComponents = URLComponents(string: "https://2ybh8dang0.execute-api.ap-southeast-2.amazonaws.com/dev/merchant/location/") else {
            print("Invalid URL")
            return
        }
        
        if let locationId = UserDefaults.standard.string(forKey: "locationId") {
            urlComponents.path.append(locationId)
        } else {
            print("Location ID not found in UserDefaults")
            return
        }
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let locationResponse = try JSONDecoder().decode(LocationData.self, from: data)
                    DispatchQueue.main.async {
                        self.location = locationResponse.location
                        self.isLoading = false
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}





