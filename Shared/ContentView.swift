//
//  ContentView.swift
//  Shared
//
//  Created by Nilesh Phadtare on 04/08/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: nil, content: {
            Text("Rope Likert view: NPLikertSlider!")
                .padding()
            RopeLikrtScale().padding(45.0)
            
            Text("Rope Likert Mood view: NPLikertSlider!")
                .padding()
            RopeLikrtMoodScale().padding(45.0)
            
            Text("likert view: NpMoodScale!")
                .padding()
            NpMoodScaleView().padding(45.0)
            
            Text("Colred slider graph view: ColoredSliderGraph!")
                .padding()
            ColoredSliderView().padding(45.0)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
struct RopeLikrtMoodScale: UIViewRepresentable {

    func makeUIView(context: Context) -> NPLikertSlider {
        let likertScale = NPLikertSlider(frame: CGRect(x: 50, y: 20, width: 150, height: 60))
        return likertScale
    }
    
    func updateUIView(_ uiView: NPLikertSlider, context: Context) {
        uiView.sliderMinimumValue = 0
        uiView.sliderMaximumValue = 2
        uiView.sliderValues = ["🙁", "😊", "😀"]
        uiView.zoomSelectedValue = true
        uiView.setNeedsDisplay()
    }
    
    class RopeLikrtScaleDelegate: NSObject, NPLikertSliderDelegate {
        func didValueChange(value: Float){
            
        }
        func didEndSliding(value: Float){
            
        }
    }
}

struct RopeLikrtScale: UIViewRepresentable {

    func makeUIView(context: Context) -> NPLikertSlider {
        let likertScale = NPLikertSlider(frame: CGRect(x: 50, y: 100, width: 150, height: 60))
        return likertScale
    }
    
    func updateUIView(_ uiView: NPLikertSlider, context: Context) {
        uiView.sliderMinimumValue = 1
        uiView.sliderMaximumValue = 5
        uiView.setNeedsDisplay()
    }
    
    class RopeLikrtScaleDelegate: NSObject, NPLikertSliderDelegate {
        func didValueChange(value: Float){
            
        }
        func didEndSliding(value: Float){
            
        }
    }
}

struct NpMoodScaleView: UIViewRepresentable {

    func makeUIView(context: Context) -> NpMoodScale {
        let likertScale = NpMoodScale(frame: CGRect(x: 50, y: 100, width: 150, height: 60))
        return likertScale
    }
    
    func updateUIView(_ uiView: NpMoodScale, context: Context) {
        uiView.fillSliderColor = UIColor.blue
        uiView.emptySliderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        uiView.dotWidth = 7
        uiView.thumbColor = UIColor.blue
        uiView.barWidth = 15
        uiView.setNeedsDisplay()
        uiView.sliderMaximumValue = 5
    }
    
    class RopeLikrtScaleDelegate: NSObject, NpMoodScaleDelegate {
        func didValueChange(value: Float){}
        func didEndSliding(value: Float){}
    }
}

struct ColoredSliderView: UIViewRepresentable {

    func makeUIView(context: Context) -> ColoredSliderGraph {
        let likertScale = ColoredSliderGraph(frame: CGRect(x: 50, y: 100, width: 150, height: 60))
        return likertScale
    }
    
    func updateUIView(_ uiView: ColoredSliderGraph, context: Context) {
        uiView.setValues(lowValue: CGFloat(64), highValue: CGFloat(450), highamberValue: CGFloat(150), lowAmberValue: CGFloat(80), highredValue: CGFloat(180), lowredValue: CGFloat(64), normalValue: CGFloat(100), latestReading: CGFloat(120))
    }
    
}
