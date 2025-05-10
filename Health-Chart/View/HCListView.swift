//
//  ContentView.swift
//  Health-Chart
//
//  Created by Sourabh Ghosh on 04/05/25.
//

import SwiftUI

struct HCListView: View {
   
    @State private var showDetails = false
    @State var data: [Sale]  = SalesData.last30Days
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                HCScreenHeaderView(isForListView: true)
                
                List(data, id: \.day) { selectedElement in
                    VStack(alignment: .center) {
                        Text("Weight: \(selectedElement.sales, format: .number)")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Text("Date : \(selectedElement.day, format: .dateTime.year().month().day())")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
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
