//
//  BoundingBox.swift
//  Monte-Carlo-e-x-dx
//
//  Created by Katelyn Lydeen on 2/4/22.
//

import Foundation
import SwiftUI

class BoundingBox: NSObject {
    
    /// calculateVolume
    /// - Parameters:
    ///   - side1Length: the length of the first side
    ///   - side2Length: the length of the second side
    ///   - side3Length: the length of the third side
    /// - Returns: the volume of the box
    func calculateVolume(side1Length: Double, side2Length: Double, side3Lenth: Double) -> Double {
        return (side1Length * side2Length * side3Lenth)
    }
    
    /// calculateSurfaceArea
    /// - Parameters:
    ///   - numberOfSides: the number of sides for the box (typically 6 for 3D, 2 for 2D)
    ///   - side1Length: the length of the first side
    ///   - side2Length: the length of the second side
    ///   - side3Length: the length of the third side
    /// - Returns: the surface area of the box (0.0 if the number of sides is anything but 2 or 6)
    func calculateSurfaceArea(numberOfSides: Int, side1Length: Double, side2Length: Double, side3Lenth: Double) -> Double {
        var surfaceArea = 0.0
        if numberOfSides == 2 {
            surfaceArea = side1Length * side2Length
        } else if numberOfSides == 6 {
            surfaceArea = 2*side1Length*side2Length + 2*side2Length*side3Lenth + 2*side1Length*side3Lenth
        }
        return surfaceArea
    }
    
}
