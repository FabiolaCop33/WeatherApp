//
//  ContentView.swift
//  WeatherApp
//
//  Created by Fabiola Correa Padilla on 22/10/24.
//

import SwiftUI

struct WeatherReport: Codable {
    let flightNumber: String
    let origin: WeatherData
    let destination: WeatherData

    struct WeatherData: Codable {
        let city: String
        let temperature: Double
        let conditions: String
    }
}

struct ContentView: View {
    @State private var weatherReport: WeatherReport?
    @State private var errorMessage: String?
    
    let apiUrl = "http://localhost:8080/api/weather/40119/Mexico/MX/Monterrey/MX"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let report = weatherReport {
                    Text("Flight Number: \(report.flightNumber)")
                        .font(.headline)
                    
                    VStack {
                        Text("🌤 Origin: \(report.origin.city)")
                        Text("Temperature: \(report.origin.temperature, specifier: "%.1f")°C")
                        Text("Conditions: \(report.origin.conditions)")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("🌤 Destination: \(report.destination.city)")
                        Text("Temperature: \(report.destination.temperature, specifier: "%.1f")°C")
                        Text("Conditions: \(report.destination.conditions)")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ProgressView("Loading Weather Report...")
                }
            }
            .padding()
            .onAppear {
                fetchWeatherReport()
            }
            .navigationTitle("Flight Weather Report")
        }
    }
    
    func fetchWeatherReport() {
        guard let url = URL(string: apiUrl) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let report = try JSONDecoder().decode(WeatherReport.self, from: data)
                DispatchQueue.main.async {
                    self.weatherReport = report
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
