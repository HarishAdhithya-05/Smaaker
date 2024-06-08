//
//  WelcomView.swift
//  Smaaker1
//
//  Created by Harish Adhithya on 10/06/24.
//

import Foundation
import SwiftUI
struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 92) // Adjust height for top spacing

            Text("Welcome to")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Pizza Hut")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            Text("You can now explore our menu's and enjoy your experience")
                .frame(width: 331, height: 100) // Adjust the frame size as needed
                .multilineTextAlignment(.center)

            Spacer()

            // Continue button
            NavigationLink(destination: InitialView()) {
                Text("Continue")
                    .frame(width: 330, height: 60)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer().frame(height: 50) // Adjust height for bottom spacing
        }
        .navigationBarBackButtonHidden(true) // Hide the back button to prevent going back to the initial page
    }
}
