//
//  ContentView.swift
//  Health-Chart
//
//  Created by Sourabh Ghosh on 04/05/25.
//

import SwiftUI

struct HCListView: View {
    
    
    @State private var showDetails = false
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 40) {
                
                HCScreenHeaderView()
                List {
                    Text("Hello World")
                    Text("Hello World")
                    Text("Hello World")
                }
                Button {
                    showDetails = true
                } label: {
                    Text("Next >")
                        .frame(maxWidth: .infinity,maxHeight: 50)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .background(Color.yellow)
                }.padding()
                
            }
            .navigationTitle("List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showDetails) {
                HCChartDetailsView(isOverview: false)
            }
            
        }
        
    }
}


#Preview {
    HCListView()
}
