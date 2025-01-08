//
//  UserSettings.swift
//  3things
//
//  Created by Matthieu Draveny on 02/01/2025.
//

import SwiftUI

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

class UserSettings: ObservableObject {
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

// OnboardingView.swift
struct OnboardingView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name: String = ""
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            let _ = print("OnboardingView is rendering")
            Text("Welcome to 3things Journal")
                .font(.system(size: 32, weight: .bold))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            Text("Your daily writing companion")
                .font(.title2)
                .foregroundColor(.secondary)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("What's your name?")
                    .font(.headline)
                
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
            }
            .padding(.top, 20)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            Button(action: completeOnboarding) {
                Text("Start Journaling")
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(name.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(name.isEmpty)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private func completeOnboarding() {
        userSettings.userName = name
        userSettings.hasCompletedOnboarding = true
        // Create the first journal entry
        DocumentManager.shared.createNewEntry()
    }
}

struct TimeGreetingView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    private let quotes = [
        Quote(text: "You are what you repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu"),
        Quote(text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier"),
        Quote(text: "It is not the strongest of the species that survive, nor the most intelligent, but the one most responsive to change.", author: "Charles Darwin"),
        Quote(text: "We are what we repeatedly do. Greatness then is not an act, but a habit.", author: "Will Durant"),
        Quote(text: "You don't have to be great to start, but you have to start to be great.", author: "Zig Ziglar"),
        Quote(text: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.", author: "John C. Maxwell"),
        Quote(text: "Motivation is what gets you started. Habit is what keeps you going.", author: "Jim Ryun"),
        Quote(text: "What lies in our power to do, lies in our power not to do.", author: "Aristotle"),
        Quote(text: "Success is not just about what you accomplish in your life, it's about what you inspire others to do.", author: "Unknown"),
        Quote(text: "Your life doesn't get better by chance, it gets better by change.", author: "Jim Rohn"),
        Quote(text: "Discipline is the bridge between goals and accomplishment.", author: "Jim Rohn"),
        Quote(text: "The secret of your future is hidden in your daily routine.", author: "Mike Murdock"),
        Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
        Quote(text: "Habits are the compound interest of self-improvement.", author: "James Clear"),
        Quote(text: "What we fear doing most is usually what we most need to do.", author: "Tim Ferriss"),
        Quote(text: "Change your habits, change your life.", author: "Unknown"),
        Quote(text: "If you want to change your life, change your habits.", author: "Unknown"),
        Quote(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
        Quote(text: "The difference between who you are and who you want to be is what you do.", author: "Unknown"),
        Quote(text: "Success is the product of daily habits, not once-in-a-lifetime transformations.", author: "James Clear"),
        Quote(text: "Every action you take is a vote for the type of person you wish to become.", author: "James Clear"),
        Quote(text: "The more you engage in positive habits, the better you will feel.", author: "Unknown"),
        Quote(text: "Small steps every day lead to big changes over time.", author: "Unknown"),
        Quote(text: "Good habits are worth being fanatical about.", author: "John Irving"),
        Quote(text: "You cannot change your destination overnight, but you can change your direction overnight.", author: "Jim Rohn"),
        Quote(text: "A year from now you may wish you had started today.", author: "Karen Lamb"),
        Quote(text: "Your habits will determine your future.", author: "Jack Canfield"),
        Quote(text: "Success isn't just about what you accomplish in your life; it's about what you inspire others to do.", author: "Unknown"),
        Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson")
    ]
    
    private var greeting: String {
           let hour = Calendar.current.component(.hour, from: Date())
           switch hour {
           case 0..<12: return "Good Morning"
           case 12..<17: return "Good Afternoon"
           default: return "Good Evening"
           }
       }
    
    private var todaysQuote: Quote {
            // Get today's date components
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Use the day of the year as an index into the quotes array
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
            
            // Use modulo to wrap around to the beginning of the array if we exceed its length
            let index = (dayOfYear - 1) % quotes.count
            return quotes[index]
        }
        
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(userSettings.userName)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Add the quote view
                VStack(alignment: .leading, spacing: 4) {
                    Text(todaysQuote.text)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    Text("- \(todaysQuote.author)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 30)  // Significantly increased top padding to create more space
        }
    }
