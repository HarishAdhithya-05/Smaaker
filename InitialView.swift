//
//  InitialView.swift
//  Smaaker1
//
//  Created by Harish Adhithya on 10/06/24.
//
import SwiftUI
import UIKit
struct InitialView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 50) // Adjust height for top spacing
                
                // Add your image here
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 273)
                
                Image("Image 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 358, height: 137)
                
                Image("Image 2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
                    .padding()
                
                Spacer()
                
                Text("Your table number is 15")
                    .frame(width: 313, height: 27)
                
                Spacer()
                
                // Continue button
                NavigationLink(destination: NextView()) {
                    Text("Continue")
                        .frame(width: 330, height: 60)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer().frame(height: 50) // Adjust height for bottom spacing
            }
        }
    }
}
struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}

