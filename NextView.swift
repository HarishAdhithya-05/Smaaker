import SwiftUI

struct NextView: View {
    @State private var searchText: String = ""
    @State private var selectedCategoryIndex: Int?
    let foodCategories = ["Burger", "Chicken", "Coffee", "Pizza", "Pasta", "Salad", "Dessert"]
    
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
                            ForEach(foodCategories.indices, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        selectedCategoryIndex = index
                                        proxy.scrollTo(index)
                                    }
                                }) {
                                    Text(foodCategories[index])
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
                
                if let index = selectedCategoryIndex {
                    if index < foodCategories.count {
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
    }
}
// UIViewRepresentable for UITextField
struct SearchBar: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }

    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Search..."
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.setLeftPaddingPoints(10)
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
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
