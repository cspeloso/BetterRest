//
//  ContentView.swift
//  BetterRest
//
//  Created by Chris Peloso on 1/2/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
       
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    @State private var recommendedBedTime = "-"
    
    var computedBedTime: String {
        get{
            var bedtimeStr = ""
            
            do{
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                                
                bedtimeStr = sleepTime.formatted(date: .omitted, time: .shortened)

            }catch{
                bedtimeStr = "-"
            }
            
            return bedtimeStr
        }
    }
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section{
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("Coffee", selection: $coffeeAmount)
                    {
                        ForEach(1...20, id:\.self){ number in
                            Text(String(number))
                        }
                    }
                    .labelsHidden()
                }
                
                Section{
                    Text("Your recommended bedtime")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(computedBedTime)
                        .font(.title3)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
