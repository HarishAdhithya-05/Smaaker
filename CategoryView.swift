import SwiftUI

struct ApiResponse: Codable {
    let status: Bool
    let items: [Merchant]
}

struct Merchant: Codable {
    let merchantId: String
    let items: [String: Category] // Changed to a dictionary to accommodate multiple categories
}

struct Category: Codable {
    let categoryName: String
    let categoryView: String
    let categoryOrder: String
    let items: [Item]
}

struct Item: Codable {
    let itemDetails: ItemDetails
    let modifierListInfo: [String] // Placeholder for now, adjust as per actual data
    let variations: [ItemVariation] // Placeholder for now, adjust as per actual data
}

struct ItemDetails: Codable {
    let availableLocation: [String]
    let imageUrl: String // Ensure this property is included
    let itemData: ItemData
    let presentAtAllLocations: Bool
    let id: String
    let type: String
    let version: String
    let recommendedStatus: Bool
    let itemId: String
    let labels: [String]
    let description: String
    let enabled: Bool
}

struct ItemData: Codable {
    let descriptionPlaintext: String
    let isArchived: Bool
    let description: String
    let name: String
    let imageUrls: [String]
}

struct ItemVariation: Codable {
    let optionsLength: String
    let availableLocation: [String]
    let customAttributeValues: CustomAttributeValues
    let itemVariationData: ItemVariationData
    let options: [String]
    let presentAtAllLocations: Bool
    let id: String
    let type: String
    let version: String
    let updatedAt: String // Adjust date handling if needed
}

struct ItemVariationData: Codable {
    let name: String
    let itemId: String
    let sku: String
    let priceMoney: PriceMoney
    let ordinal: String
    let pricingType: String
}

struct CustomAttributeValues: Codable {
    let name: String
    let booleanValue: Bool
}

struct PriceMoney: Codable {
    let amount: Int
    let currency: String
}

class CategoryViewModel: ObservableObject {
    @Published var categories: [String: Category] = [:]
    @Published var isLoading = false
    
    func fetchCategoryData() {
        guard let url = URL(string: "https://2ybh8dang0.execute-api.ap-southeast-2.amazonaws.com/dev/merchant/master/allitems/smaaker-4574-a7bc-0bdd/LP960V7BZ3Y61") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                if let firstMerchant = apiResponse.items.first {
                    DispatchQueue.main.async {
                        self.categories = firstMerchant.items
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
                print("Response data: \(String(describing: String(data: data, encoding: .utf8)))")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct CategoryDataView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if viewModel.categories.isEmpty {
                Text("Failed to load category data")
            } else {
                List {
                    ForEach(viewModel.categories.keys.sorted(), id: \.self) { key in
                        if let category = viewModel.categories[key] {
                            Section(header: Text(category.categoryName)
                                        .font(.largeTitle)
                                        .padding()) {
                                ForEach(category.items, id: \.itemDetails.itemData.name) { item in
                                    VStack(alignment: .leading) {
                                        Text(item.itemDetails.itemData.name)
                                            .font(.headline)
                                        
                                        Text(item.itemDetails.itemData.description)
                                            .font(.subheadline)
                                        Text(" Labels:\(item.itemDetails.labels.joined(separator: " "))")
                                                                                    .font(.subheadline)
                                        // Display image if imageUrl is not empty
                                        if !item.itemDetails.imageUrl.isEmpty {
                                            AsyncImage(url: URL(string: item.itemDetails.imageUrl)) { image in
                                                image.resizable()
                                                     .aspectRatio(contentMode: .fit)
                                                     .frame(maxWidth: 100, maxHeight: 100)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                        
                                        // Display available locations
                                        Text("Available Locations: \(item.itemDetails.availableLocation.joined(separator: ", "))")
                                            .font(.subheadline)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchCategoryData()
        }
    }
}

// Preview
struct CategoryDataView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDataView()
    }
}
