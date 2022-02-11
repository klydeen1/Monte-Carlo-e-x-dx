//
//  DrawingView.swift
//  Monte-Carlo-e-x-dx
//
//  Created by Katelyn Lydeen on 2/10/22.
//

//
//  DrawingView.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//
import SwiftUI

struct drawingView: View {
    
    @Binding var redLayer : [(xPoint: Double, yPoint: Double)]
    @Binding var blueLayer : [(xPoint: Double, yPoint: Double)]
    
    var body: some View {
    
        
        ZStack{
        
            drawIntegral(drawingPoints: redLayer )
                .stroke(Color.red)
            
            drawIntegral(drawingPoints: blueLayer )
                .stroke(Color.blue)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
        
    }
}

struct DrawingView_Previews: PreviewProvider {
    
    @State static var redLayer : [(xPoint: Double, yPoint: Double)] = [(-0.5, 0.5), (0.5, 0.5), (0.0, 0.0), (0.0, 1.0)]
    @State static var blueLayer : [(xPoint: Double, yPoint: Double)] = [(-0.5, -0.5), (0.5, -0.5), (0.9, 0.0)]
    
    static var previews: some View {
       
        drawingView(redLayer: $redLayer, blueLayer: $blueLayer)
            .aspectRatio(1, contentMode: .fill)
            //.drawingGroup()
           
    }
}



struct drawIntegral: Shape {
    
   
    let smoothness : CGFloat = 1.0
    var drawingPoints: [(xPoint: Double, yPoint: Double)]  ///Array of tuples
    
    func path(in rect: CGRect) -> Path {
        
        // draw from the center of our rectangle
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let scale = rect.width
        

        // Create the Path for the display
        var path = Path()
        
        for item in drawingPoints {
            
            path.addRect(CGRect(x: item.xPoint*Double(scale), y: item.yPoint*Double(-scale)+2.0*Double(center.y), width: 1.0 , height: 1.0))
            
        }


        return (path)
    }
}
