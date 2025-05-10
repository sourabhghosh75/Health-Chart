//
//  HCChartDetailsView.swift
//  Health-Chart
//
//  Created by Sourabh Ghosh on 05/05/25.
//

import SwiftUI
import Charts

extension Sale {
    func isAbove(threshold: Double) -> Bool {
        self.sales > Int(threshold)
    }
}

struct HCChartDetailsView: View {
    var isOverview: Bool

    @State var data: [Sale]
    @State private var lineWidth = 2.0
    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .green
    @State private var showSymbols = true
    @State private var selectedElement: Sale? = SalesData.last30Days[10]
    @State private var showLollipop = true
    @State private var lollipopColor: Color = .red

    init(isOverview: Bool) {
        self.isOverview = isOverview
        self.data = SalesData.last30Days
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 40) {
                
                HCScreenHeaderView()
                if isOverview {
                    chart
                        .allowsHitTesting(false)
                } else {
                    List {
                        Section {
                            chart
                        }
                    }
                    .navigationBarTitle("Chart Details", displayMode: .inline)
                }
            }
            
        }
    }

    private func CompareSelectedMarkerToChartMarker<T: Equatable>(selectedMarker: T, chartMarker: T) -> Bool {
          return selectedMarker == chartMarker
      }

    private func getBaselineMarker (marker: Sale) -> some ChartContent {
        return LineMark(
            x: .value("Date", marker.day),
            y: .value("Sales", marker.sales)
        )
        .accessibilityLabel(marker.day.formatted(date: .complete, time: .omitted))
        .accessibilityValue("\(marker.sales) sold")
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .foregroundStyle(chartColor)
        .interpolationMethod(interpolationMethod.mode)
        .symbolSize(showSymbols ? 60 : 0)
    }
    
      private var chart: some View {
          Chart(data, id: \.day) { chartMarker in
              let baselineMarker = getBaselineMarker(marker: chartMarker)
              if CompareSelectedMarkerToChartMarker(selectedMarker: selectedElement, chartMarker: chartMarker) && showLollipop {
                  baselineMarker.symbol() {
                      Circle().strokeBorder(chartColor, lineWidth: 2).background(Circle().foregroundColor(lollipopColor)).frame(width: 11)
                  }
              } else {
                  baselineMarker.symbol(Circle().strokeBorder(lineWidth: lineWidth))
              }
          }
          .chartOverlay { proxy in
              GeometryReader { geo in
                  Rectangle().fill(.clear).contentShape(Rectangle())
                      .gesture(
                          SpatialTapGesture()
                              .onEnded { value in
                                  let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                  if selectedElement?.day == element?.day {
                                      // If tapping the same element, clear the selection.
                                      selectedElement = nil
                                  } else {
                                      selectedElement = element
                                  }
                              }
                              .exclusively(
                                  before: DragGesture()
                                      .onChanged { value in
                                          selectedElement = findElement(location: value.location, proxy: proxy, geometry: geo)
                                      }
                              )
                      )
              }
          }
          .chartBackground { proxy in
              ZStack(alignment: .topLeading) {
                  GeometryReader { geo in
                      if showLollipop,
                         let selectedElement {
                          let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day)!
                          let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0

                          let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                          let lineHeight = geo[proxy.plotAreaFrame].maxY
                          let boxWidth: CGFloat = 100
                          let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                          Rectangle()
                              .fill(lollipopColor)
                              .frame(width: 2, height: lineHeight)
                              .position(x: lineX, y: lineHeight / 2)

                          VStack(alignment: .center) {
                              Text("\(selectedElement.day, format: .dateTime.year().month().day())")
                                  .font(.callout)
                                  .foregroundStyle(.secondary)
                              Text("\(selectedElement.sales, format: .number)")
                                  .font(.title2.bold())
                                  .foregroundColor(.primary)
                          }
                          .accessibilityElement(children: .combine)
                          .accessibilityHidden(isOverview)
                          .frame(width: boxWidth, alignment: .leading)
                          .background {
                              ZStack {
                                  RoundedRectangle(cornerRadius: 8)
                                      .fill(.background)
                                  RoundedRectangle(cornerRadius: 8)
                                      .fill(.quaternary.opacity(0.7))
                              }
                              .padding(.horizontal, -8)
                              .padding(.vertical, -4)
                          }
                          .offset(x: boxOffset)
                      }
                  }
              }
          }
          .chartXAxis(isOverview ? .hidden : .automatic)
          .chartYAxis(isOverview ? .hidden : .automatic)
          .accessibilityChartDescriptor(self)
          .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
      }

      private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Sale? {
          let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
          if let date = proxy.value(atX: relativeXPosition) as Date? {
              // Find the closest date element.
              var minDistance: TimeInterval = .infinity
              var index: Int? = nil
              for salesDataIndex in data.indices {
                  let nthSalesDataDistance = data[salesDataIndex].day.distance(to: date)
                  if abs(nthSalesDataDistance) < minDistance {
                      minDistance = abs(nthSalesDataDistance)
                      index = salesDataIndex
                  }
              }
              if let index {
                  return data[index]
              }
          }
          return nil
      }
}

extension HCChartDetailsView: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        AccessibilityHelpers.chartDescriptor(forSalesSeries: data, isContinuous: true)
    }
}

#Preview {
    HCChartDetailsView(isOverview: true)
    HCChartDetailsView(isOverview: false)
}
