import SwiftUI
import Combine

// Merchant Data Model
struct MerchantData: Codable {
    let status: Bool
    let merchant: MerchantDetails
}

struct MerchantDetails: Codable {
    let business_name: String
    let smaakerMerchantId: String
    let main_location_id: String
    let merchantName: String
    let accessToken: String
    let email: String
    let country: String
    // Add other properties you need...
}

// Merchant View Model
class MerchantViewModel: ObservableObject {
    @Published var merchant: MerchantDetails?
    @Published var isLoading = false

    func fetchMerchantDetails(for merchantId: String) {
        guard var urlComponents = URLComponents(string: "https://2ybh8dang0.execute-api.ap-southeast-2.amazonaws.com/dev/merchant/merchant/") else { return }
        
        // Appending the merchantId to the URL
        urlComponents.path.append(merchantId)
        print(urlComponents)
        guard let url = urlComponents.url else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let merchantResponse = try JSONDecoder().decode(MerchantData.self, from: data)
                    DispatchQueue.main.async {
                        self.merchant = merchantResponse.merchant
                        self.saveAccessTokenAsCookie(merchantResponse.merchant.accessToken)
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
    
    private func saveAccessTokenAsCookie(_ accessToken: String) {
        // Create a cookie
        let cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .name: "accessToken",
            .value: accessToken,
            .domain: "2ybh8dang0.execute-api.ap-southeast-2.amazonaws.com", // Replace with your actual domain
            .path: "/",
            .secure: true,
            .expires: Date(timeIntervalSinceNow: 3600) // 1 hour expiry time
        ]
        
        if let cookie = HTTPCookie(properties: cookieProperties) {
            HTTPCookieStorage.shared.setCookie(cookie)
            print("Cookies set successfully")
        } else {
            print("Failed to create cookie")
        }
    }
}

struct WelcomeView: View {
    @StateObject private var merchantViewModel = MerchantViewModel()
    @StateObject private var locationViewModel = LocationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
               Image("horilogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 273)

                if locationViewModel.isLoading {
                    ProgressView()
                } else if let location = locationViewModel.location {
                    
                    VStack{
                        HStack {
                            Text("\(location.nickName)")
                                .padding(.leading)
                            Spacer()
                            Text("""
                                \(location.locationDetail.address.locality),
                                \(location.locationDetail.address.addressLine1),
                                \(location.locationDetail.address.addressLine2) \(location.locationDetail.address.country)
                                """)
                                .padding(.trailing)
                        }
                        
                    }.background(Color(red: 0.97, green: 0.87, blue: 0.59))
                        .padding(.horizontal)

                    
                  Text("\(location.locationDetail.businessName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                    Text(" \(location.locationDetail.address.addressLine1), \(location.locationDetail.address.locality), \(location.locationDetail.address.country) ")
                        .fontWeight(.bold)
                      .frame(width: 331, height: 189)
                    
                    // Add other location properties as needed...
                } else {
                    Text("Failed to load location details")
                }
                
                Spacer().frame(height: 92) // Adjust height for top spacing
                
                Spacer()
                // Continue button
                NavigationLink(destination: InitialView()) {
                    Text("Continue")
                        .frame(width: 330, height: 60)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
                
                Spacer().frame(height: 50) // Adjust height for bottom spacing
            }
            .padding()
            .onAppear {
                if let scannedMerchantId = UserDefaults.standard.string(forKey: "merchantId") {
                    merchantViewModel.fetchMerchantDetails(for: scannedMerchantId)
                }
                if let locationId = UserDefaults.standard.string(forKey: "locationId"),
                   let outpost = UserDefaults.standard.string(forKey: "outpost") {
                    locationViewModel.fetchLocationDetails(outpost: outpost)
                }
                
            }
            .navigationBarBackButtonHidden(false) // Ensure the back button is shown
        }
    }
}

// Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            WelcomeView()
        }
    }
}
