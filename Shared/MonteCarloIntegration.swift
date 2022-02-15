//
//  MonteCarloIntegration.swift
//  Monte-Carlo-e-x-dx
//
//  Created by Katelyn Lydeen on 2/4/22.
//

import Foundation
import SwiftUI

typealias integrationFunctionHandler = (_ numberOfDimensions: Int, _ arrayOfInputs: [Double]) -> Double

class MonteCarloIntegration: NSObject, ObservableObject {
    @MainActor @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @MainActor @Published var outsideData = [(xPoint: Double, yPoint: Double)]()
    @Published var totalGuessesString = ""
    @Published var guessesString = ""
    @Published var integralString = ""
    @Published var errorString = ""
    @Published var enableButton = true
    
    var plotDataModel: PlotDataClass? = nil
    var plotError: Bool = false
    
    var integral = 0.0
    var guesses = 1
    var totalGuesses = 0
    var totalIntegral = 0.0
    var firstTimeThroughLoop = true
    var firstTimeRunning = true
    var error = 0.0
    
    @MainActor init(withData data: Bool) {
        super.init()
        insideData = []
        outsideData = []
    }
    
    
    func calculateIntegralEToTheMinusX() async {
        var maxGuesses = 0.0
        let xMin = 0.0
        let xMax = 1.0
        let yMin = 0.0
        let yMax = exp(-xMin)
        let boundingBoxCalculator = BoundingBox()
        
        maxGuesses = Double(guesses)
        
        let newValue = await calculateMonteCarloIntegral(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, maxGuesses: maxGuesses)
        
        totalIntegral += newValue
        totalGuesses += guesses
        
        await updateTotalGuessesString(text: "\(totalGuesses)")
        
        integral = (totalIntegral/Double(totalGuesses)*boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, side1Length: (xMax-xMin), side2Length: (yMax-yMin), side3Lenth: 0.0))
        
        if firstTimeRunning {
            plotDataModel!.zeroData()
            //set the Plot Parameters
            plotDataModel!.changingPlotParameters.yMax = 1.0
            plotDataModel!.changingPlotParameters.yMin = -10.0
            plotDataModel!.changingPlotParameters.xMax = 10.0
            plotDataModel!.changingPlotParameters.xMin = -0.1
            plotDataModel!.changingPlotParameters.xLabel = "log(n)"
            plotDataModel!.changingPlotParameters.yLabel = "log(abs(Error))"
            plotDataModel!.changingPlotParameters.lineColor = .red()
            plotDataModel!.changingPlotParameters.title = "Error of the integral vs n"
        }
        
        let actualIntegral = -exp(-1.0) + 1.0
        print(actualIntegral)
        let numerator = abs(integral - actualIntegral)
        error = log10(numerator/actualIntegral)
        
        var plotData :[plotDataType] =  []
        let errorDataPoint: plotDataType = [.X: log10(Double(totalGuesses)), .Y: (error)]
        plotData.append(contentsOf: [errorDataPoint])
        //plotDataModel?.appendData(dataPoint: [errorDataPoint])
        plotDataModel?.appendData(dataPoint: plotData)
        
        firstTimeRunning = false
        
        await updateIntegralString(text: "\(integral)")
        await updateErrorString(text: "\(error)")
    }
    
    /// calculates the Monte Carlo Integral of exp(x)
    /// - Parameters:
    ///   - xMin: minimum x value of the integral/bounding box
    ///   - xMax: maximum x value of the integral/bounding box
    ///   - yMin: minimum y value of the function within the bounding box
    ///   - yMax: maximum y value of the function within the bounding box
    ///   - maxGuesses: number of guesses to use in the calculaton
    /// - Returns: ratio of points inside to total guesses. Must mulitply by area of box in calling function
    func calculateMonteCarloIntegral(xMin: Double, xMax: Double, yMin: Double, yMax: Double, maxGuesses: Double) async -> Double {
        
        var numberOfGuesses = 0.0
        var pointsInArea = 0.0
        var integral = 0.0
        var point = (xPoint: 0.0, yPoint: 0.0)
        
        var newInsidePoints : [(xPoint: Double, yPoint: Double)] = []
        var newOutsidePoints : [(xPoint: Double, yPoint: Double)] = []
        
        while numberOfGuesses < maxGuesses {
            /* Calculate 2 random values within the box
             * Determine the value of the function exp(x) at the randomized x value
             * If the randomized y value is less than the function value, the point is within the integral
             */
            //point.xPoint = Double.random(in: xMin...xMax)
            //point.yPoint = Double.random(in: yMin...yMax)
            point.xPoint = Double.random(in: 0.0...1.0)
            point.yPoint = Double.random(in: 0.0...1.0)
            
            let functionValue = exp(-point.xPoint)
            
            // If the y value is at or lower than the actual function value at the randomized x value, it's within the area and should be added to the number of points in the area
            if((point.yPoint - functionValue) <= 0.0) {
                pointsInArea += 1.0
                newInsidePoints.append(point)
            }
            else { // If outside the area do not add to the number of points in the integral
                newOutsidePoints.append(point)
            }
            
            numberOfGuesses += 1.0
            
            }
        
        integral = Double(pointsInArea)
        
        //Append the points to the arrays needed for the displays
        //Don't attempt to draw more than 250,000 points to keep the display updating speed reasonable.
        
        if ((totalGuesses < 500001) || (firstTimeThroughLoop)){
        
            // insideData.append(contentsOf: newInsidePoints)
            // outsideData.append(contentsOf: newOutsidePoints)
            
            var plotInsidePoints = newInsidePoints
            var plotOutsidePoints = newOutsidePoints
            
            if (newInsidePoints.count > 750001) {
                
                plotInsidePoints.removeSubrange(750001..<newInsidePoints.count)
            }
            
            if (newOutsidePoints.count > 750001){
                plotOutsidePoints.removeSubrange(750001..<newOutsidePoints.count)
                
            }
            
            await updateData(insidePoints: plotInsidePoints, outsidePoints: plotOutsidePoints)
            firstTimeThroughLoop = false
        }
        
        return integral
    }
    
    /// updateData
    /// The function runs on the main thread so it can update the GUI
    /// - Parameters:
    ///   - insidePoints: points inside the circle of the given radius
    ///   - outsidePoints: points outside the circle of the given radius
    @MainActor func updateData(insidePoints: [(xPoint: Double, yPoint: Double)] , outsidePoints: [(xPoint: Double, yPoint: Double)]){
        
        insideData.append(contentsOf: insidePoints)
        outsideData.append(contentsOf: outsidePoints)
    }
    
    /// updateTotalGuessesString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the number of total guesses
    @MainActor func updateTotalGuessesString(text:String){
        self.totalGuessesString = text
    }
    
    /// updateIntegralString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the current value of the integral
    @MainActor func updateIntegralString(text:String){
        self.integralString = text
    }
    
    /// updateErrorString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the current value of the integral
    @MainActor func updateErrorString(text:String){
        self.errorString = text
    }
    
    /// setButtonEnable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool){
        if state {
            Task.init {
                await MainActor.run {
                    self.enableButton = true
                }
            }
        }
        else{
            Task.init {
                await MainActor.run {
                    self.enableButton = false
                }
            }
        }
    }
}
