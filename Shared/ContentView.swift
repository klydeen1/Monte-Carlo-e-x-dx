//
//  ContentView.swift
//  Shared
//
//  Created by Katelyn Lydeen on 2/4/22.
//

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    @ObservedObject var plotDataModel = PlotDataClass(fromLine: true)
    @State var totalGuesses = 0.0
    @State var totalIntegral = 0.0
    @State var guessString = "23458"
    @State var totalGuessString = "0"
    @State var integralString = "0.0"
    @State var errorString = "0.0"
    
    
    // Setup the GUI to monitor the data from the Monte Carlo Integral Calculator
    @ObservedObject var monteCarlo = MonteCarloIntegration(withData: true)
    
    var body: some View {
        HStack{
            VStack{
                VStack(alignment: .center) {
                    Text("Guesses")
                        .font(.callout)
                        .bold()
                    TextField("# Guesses", text: $guessString)
                        .padding()
                }
                .padding(.top, 5.0)
                
                VStack(alignment: .center) {
                    Text("Total Guesses")
                        .font(.callout)
                        .bold()
                    TextField("# Total Guesses", text: $totalGuessString)
                        .padding()
                }
                
                VStack(alignment: .center) {
                    Text("Integral of exp(x)")
                        .font(.callout)
                        .bold()
                    TextField("# Integral", text: $integralString)
                        .padding()
                }
                
                VStack(alignment: .center) {
                    Text("Error (log scale)")
                        .font(.callout)
                        .bold()
                    TextField("# Log of error", text: $errorString)
                        .padding()
                }
                
                Button("Cycle Calculation", action: {Task.init{await self.integrateFunc()}})
                    .padding()
                    .disabled(monteCarlo.enableButton == false)
                
                Button("Clear", action: {self.clear()})
                    .padding(.bottom, 5.0)
                    .disabled(monteCarlo.enableButton == false)
                
                if (!monteCarlo.enableButton){
                    
                    ProgressView()
                }
            }
            .padding()
            //DrawingField
            drawingView(redLayer:$monteCarlo.insideData, blueLayer:$monteCarlo.outsideData)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
            
            CorePlot(dataForPlot: $plotDataModel.plotData, changingPlotParameters: $plotDataModel.changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            
            Divider()
        }
    }
    
    func integrateFunc() async {
        monteCarlo.plotDataModel = self.plotDataModel
        
        monteCarlo.setButtonEnable(state: false)
        
        monteCarlo.guesses = Int(guessString)!
        monteCarlo.totalGuesses = Int(totalGuessString) ?? Int(0.0)
        
        await monteCarlo.calculateIntegralEToTheMinusX()
        
        totalGuessString = monteCarlo.totalGuessesString
        
        integralString =  monteCarlo.integralString
        
        errorString = monteCarlo.errorString
        
        monteCarlo.setButtonEnable(state: true)
        
    }
    
    func clear(){
        plotDataModel.zeroData()
        guessString = "23458"
        totalGuessString = "0.0"
        integralString =  ""
        monteCarlo.totalGuesses = 0
        monteCarlo.totalIntegral = 0.0
        monteCarlo.insideData = []
        monteCarlo.outsideData = []
        monteCarlo.firstTimeThroughLoop = true
        monteCarlo.firstTimeRunning = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
