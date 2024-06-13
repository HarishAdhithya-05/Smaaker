import SwiftUI

import Foundation

struct FoodCategory: Identifiable, Codable {
    let id: String
    let name: String
    let categoryName : String
    // Add other properties if needed
}

struct APIResponse: Codable {
    let categories: [FoodCategory]
}
import SwiftUI
import Combine

class FoodCategoryViewModel: ObservableObject {
    @Published var foodCategories: [FoodCategory] = []
    @Published var selectedCategoryIndex: Int?

    private var cancellables = Set<AnyCancellable>()
    
    func fetchCategories() {
        guard let url = URL(string: "https://2ybh8dang0.execute-api.ap-southeast-2.amazonaws.com/dev/merchant/master/allitems/smaaker-4574-a7bc-0bdd/LP960V7BZ3Y61") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .map { $0.categories }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.foodCategories, on: self)
            .store(in: &cancellables)
    }
}
import SwiftUI

struct NextView: View {
    @StateObject private var viewModel = FoodCategoryViewModel()
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Restaurant")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding([.leading, .top], 20)
                Spacer()
            }

            // Add the search bar
            SearchBar(text: $searchText)
                .frame(height: 40)
                .padding(.horizontal)

            // Food categories layout
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Food Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Replace FoodCategoryButton with ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.foodCategories.indices, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        viewModel.selectedCategoryIndex = index
                                        proxy.scrollTo(index)
                                    }
                                }) {
                                    Text(viewModel.foodCategories[index].name)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                if let index = viewModel.selectedCategoryIndex {
                    if index < viewModel.foodCategories.count {
                        Image("Image \(index + 1)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 390, height: 117)
                    }
                }
                
            }
            Spacer()
        }
        .navigationBarTitle("Next Page", displayMode: .inline)
        .onAppear {
            viewModel.fetchCategories()
        }
    }
}

// Dummy SearchBar implementation for completeness
struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}


// Add your SwiftUI view extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
struct NextView_Previews: PreviewProvider {
    static var previews: some View {
        NextView()
    }
}
