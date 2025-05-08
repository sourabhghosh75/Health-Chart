//
// Copyright © 2022 Swift Charts Examples.
// Open Source - MIT License

import SwiftUI

/*
 This file collects functions used by
 the Accessibility descriptors of charts for data that is re-used across chart types.
 
 The detailed versions simply use accessibilityLabel/accessibilityValue for each Mark.

 NOTE: Filed FB10320202 indicating some Mark types do not use label/value set on the Mark
 */

extension TimeInterval {
    var accessibilityDurationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .brief
        formatter.maximumUnitCount = 1
        
        return formatter
    }
    
    var durationDescription: String {
        let hqualifier = (hours == 1) ? "hour" : "hours"
        let mqualifier = (minutes == 1) ? "minute" : "minutes"
        
        return accessibilityDurationFormatter.string(from: self) ??
        String(format:"%d \(hqualifier) %02d \(mqualifier)", hours, minutes)
    }

    var hours: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    
    var minutes: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
}

extension Date {
    // Used for charts where the day of the week is used: visually  M/T/W etc
    // (but we want VoiceOver to read out the full day)
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        return formatter.string(from: self)
    }
}

enum AccessibilityHelpers {
    // TODO: This should be a protocol but since the data objects are in flux this will suffice
    static func chartDescriptor(forSalesSeries data: [Sale],
                                saleThreshold: Double? = nil,
                                isContinuous: Bool = false) -> AXChartDescriptor {

        // Since we're measuring a tangible quantity,
        // keeping an independant minimum prevents visual scaling in the Rotor Chart Details View
        let min = 0 // data.map(\.sales).min() ??
        let max = data.map(\.sales).max() ?? 0

        // A closure that takes a date and converts it to a label for axes
        let dateTupleStringConverter: ((Sale) -> (String)) = { dataPoint in

            let dateDescription = dataPoint.day.formatted(date: .complete, time: .omitted)

            if let threshold = saleThreshold {
                let isAbove = dataPoint.isAbove(threshold: threshold)

                return "\(dateDescription): \(isAbove ? "Above" : "Below") threshold"
            }

            return dateDescription
        }

        let xAxis = AXNumericDataAxisDescriptor(
            title: "Date index",
            range: Double(0)...Double(data.count),
            gridlinePositions: []
        ) { "Day \(Int($0) + 1)" }

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Sales",
            range: Double(min)...Double(max),
            gridlinePositions: []
        ) { value in "\(Int(value)) sold" }

        let series = AXDataSeriesDescriptor(
            name: "Daily sale quantity",
            isContinuous: isContinuous,
            dataPoints: data.enumerated().map { (idx, point) in
                    .init(x: Double(idx),
                          y: Double(point.sales),
                          label: dateTupleStringConverter(point))
            }
        )

        return AXChartDescriptor(
            title: "Sales per day",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }

    static func chartDescriptor(forLocationSeries data: [LocationData.Series]) -> AXChartDescriptor {
        let dateStringConverter: ((Date) -> (String)) = { date in
            date.formatted(date: .abbreviated, time: .omitted)
        }

        // Create a descriptor for each Series object
        // as that allows auditory comparison with VoiceOver
        // much like the chart does visually and allows individual city charts to be played
        let series = data.map { dataPoint in
            AXDataSeriesDescriptor(
                name: "\(dataPoint.city)",
                isContinuous: false,
                dataPoints: dataPoint.sales.map { data in
                        .init(x: dateStringConverter(data.weekday),
                              y: Double(data.sales),
                              label: "\(data.weekday.weekdayString)")
                }
            )
        }

        // Get the minimum/maximum within each city
        // and then the limits of the resulting list
        // to pass in as the Y axis limits
        let limits: [(Int, Int)] = data.map { seriesData in
            let sales = seriesData.sales.map { $0.sales }
            let localMin = sales.min() ?? 0
            let localMax = sales.max() ?? 0
            return (localMin, localMax)
        }

        let min = limits.map { $0.0 }.min() ?? 0
        let max = limits.map { $0.1 }.max() ?? 0

        // Get the unique days to mark the x-axis
        // and then sort them
        let uniqueDays = Set( data
            .map { $0.sales.map { $0.weekday } }
            .joined() )
        let days = Array(uniqueDays).sorted()

        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Days",
            categoryOrder: days.map { dateStringConverter($0) }
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Sales",
            range: Double(min)...Double(max),
            gridlinePositions: []
        ) { value in "\(Int(value)) sold" }

        return AXChartDescriptor(
            title: "Sales per day",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: series
        )
    }
}
