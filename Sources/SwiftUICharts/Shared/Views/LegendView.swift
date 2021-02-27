//
//  LegendView.swift
//  LineChart
//
//  Created by Will Dale on 09/01/2021.
//

import SwiftUI

/**
 Sub view to setup and display the legends.
 */
internal struct LegendView<T>: View where T: CTChartData {
    
    @ObservedObject var chartData : T
    private let columns     : [GridItem]
    private let textColor   : Color
            
    internal init(chartData: T,
                  columns  : [GridItem],
                  textColor: Color
    ) {
        self.chartData = chartData
        self.columns   = columns
        self.textColor = textColor
    }
    
    internal var body: some View {
        
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(chartData.legends) { legend in
                
                switch legend.chartType {

                case .line:
                    
                    line(legend)
                        .accessibilityLabel( Text(accessibilityLegendLabel(legend: legend)))
                        .accessibilityValue(Text("\(legend.legend)"))

                case .bar:

                    bar(legend)
                        .if(scaleLegendBar(legend: legend)) { $0.scaleEffect(1.2, anchor: .leading) }
                        .accessibilityLabel( Text(accessibilityLegendLabel(legend: legend)))
                        .accessibilityValue(Text("\(legend.legend)"))
                case .pie:

                    pie(legend)
                        .if(scaleLegendPie(legend: legend)) {
                            $0.scaleEffect(1.2, anchor: .leading)
                        }
                        .accessibilityLabel( Text(accessibilityLegendLabel(legend: legend)))
                        .accessibilityValue(Text("\(legend.legend)"))
                }
            }
        }.id(UUID())
    }
    
    private func accessibilityLegendLabel(legend: LegendData) -> String {
        switch legend.chartType {
        case .line:
            if legend.prioity == 1 {
                return "Line Chart Legend"
            } else {
                return "P O I Marker Legend"
            }
        case .bar:
            if legend.prioity == 1 {
                return "Bar Chart Legend"
            } else {
                return "P O I Marker Legend"
            }
        case .pie:
            if legend.prioity == 1 {
                return "Pie Chart Legend"
            } else {
                return "P O I Marker Legend"
            }
        }
    }
    
    /// Detects whether to run the scale effect on the legend.
    private func scaleLegendBar(legend: LegendData) -> Bool {
        
        if chartData is BarChartData {
            if let datapointID = chartData.infoView.touchOverlayInfo.first?.id as? UUID {
                return chartData.infoView.isTouchCurrent && legend.id == datapointID
            } else {
                return false
            }
        } else if chartData is GroupedBarChartData || chartData is StackedBarChartData {
            if let datapoint = chartData.infoView.touchOverlayInfo.first as? MultiBarChartDataPoint {
                return chartData.infoView.isTouchCurrent && legend.colour == datapoint.group.colour
            } else {
                return false
            }
        } else {
            return false
        }
    }
    /// Detects whether to run the scale effect on the legend.
    private func scaleLegendPie(legend: LegendData) -> Bool {
        
        if chartData is PieChartData || chartData is DoughnutChartData {
            if let datapointID = chartData.infoView.touchOverlayInfo.first?.id as? UUID {
                return chartData.infoView.isTouchCurrent && legend.id == datapointID
            } else {
                return false
            }
        } else {
           return false
       }
    }
    
    /// Returns a Line legend.
    func line(_ legend: LegendData) -> some View {
        Group {
            if let stroke = legend.strokeStyle {
                let strokeStyle = stroke.strokeToStrokeStyle()
                if let colour = legend.colour {
                    HStack {
                        LegendLine(width: 40)
                            .stroke(colour, style: strokeStyle)
                            .frame(width: 40, height: 3)
                        Text(legend.legend)
                            .font(.caption)
                            .foregroundColor(textColor)
                    }
                    
                } else if let colours = legend.colours  {
                    HStack {
                        LegendLine(width: 40)
                            .stroke(LinearGradient(gradient: Gradient(colors: colours),
                                                   startPoint: .leading,
                                                   endPoint: .trailing),
                                    style: strokeStyle)
                            .frame(width: 40, height: 3)
                        Text(legend.legend)
                            .font(.caption)
                            .foregroundColor(textColor)
                    }
                } else if let stops = legend.stops {
                    let stops = GradientStop.convertToGradientStopsArray(stops: stops)
                    HStack {
                        LegendLine(width: 40)
                            .stroke(LinearGradient(gradient: Gradient(stops: stops),
                                                   startPoint: .leading,
                                                   endPoint: .trailing),
                                    style: strokeStyle)
                            .frame(width: 40, height: 3)
                        Text(legend.legend)
                            .font(.caption)
                            .foregroundColor(textColor)
                    }
                }
            }
        }
    }
    
    /// Returns a Bar legend.
    func bar(_ legend: LegendData) -> some View {
        Group {
            if let colour = legend.colour
            {
                HStack {
                    Rectangle()
                        .fill(colour)
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
            } else if let colours = legend.colours,
                      let startPoint = legend.startPoint,
                      let endPoint = legend.endPoint
            {
                HStack {
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: colours),
                                             startPoint: startPoint,
                                             endPoint: endPoint))
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
            } else if let stops = legend.stops,
                      let startPoint = legend.startPoint,
                      let endPoint = legend.endPoint
            {
                let stops = GradientStop.convertToGradientStopsArray(stops: stops)
                HStack {
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(stops: stops),
                                             startPoint: startPoint,
                                             endPoint: endPoint))
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
            }
        }
    }
    
    /// Returns a Pie legend.
    func pie(_ legend: LegendData) -> some View {
        Group {
            if let colour = legend.colour {
                HStack {
                    Circle()
                        .fill(colour)
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
                
            } else if let colours = legend.colours,
                      let startPoint = legend.startPoint,
                      let endPoint = legend.endPoint
            {
                HStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: colours),
                                             startPoint: startPoint,
                                             endPoint: endPoint))
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
                
            } else if let stops = legend.stops,
                      let startPoint = legend.startPoint,
                      let endPoint = legend.endPoint
            {
                let stops = GradientStop.convertToGradientStopsArray(stops: stops)
                HStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(stops: stops),
                                             startPoint: startPoint,
                                             endPoint: endPoint))
                        .frame(width: 20, height: 20)
                    Text(legend.legend)
                        .font(.caption)
                }
            }
        }
    }
}
