import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var quizGame: QuizGame
    @State private var numberOfQuestions = 10
    @State private var selectedDifficulty: ChordType.ChordDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Jazz Harmony Quiz - Main Menu")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Master jazz chord theory with interactive drills")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Quiz Setup Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Quiz Setup")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Number of Questions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Questions")
                            .font(.headline)
                        
                        Picker("Questions", selection: $numberOfQuestions) {
                            ForEach([5, 10, 15, 20, 25, 30], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty Level")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(ChordType.ChordDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Question Types
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question Types")
                            .font(.headline)
                        
                        ForEach(QuestionType.allCases, id: \.self) { questionType in
                            HStack {
                                Button(action: {
                                    if selectedQuestionTypes.contains(questionType) {
                                        selectedQuestionTypes.remove(questionType)
                                    } else {
                                        selectedQuestionTypes.insert(questionType)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedQuestionTypes.contains(questionType) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedQuestionTypes.contains(questionType) ? .blue : .gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(questionType.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(questionType.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Action Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: ChordDrillView(
                        numberOfQuestions: numberOfQuestions,
                        selectedDifficulty: selectedDifficulty,
                        selectedQuestionTypes: selectedQuestionTypes
                    )) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Quiz")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedQuestionTypes.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedQuestionTypes.isEmpty)
                    
                    NavigationLink(destination: LeaderboardView()) {
                        HStack {
                            Image(systemName: "trophy")
                            Text("View Leaderboard")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            // Reset quiz state when returning to main menu
            quizGame.resetQuizState()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var quizGame: QuizGame
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Jazz Harmony Quiz")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Master jazz chord theory with interactive drills")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                NavigationLink(destination: ChordDrillView()) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.title2)
                        Text("Chord Drill")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                NavigationLink(destination: CadenceDrillView()) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                        Text("Cadence Mode (ii-V-I)")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
                }

                NavigationLink(destination: LeaderboardView()) {
                    HStack {
                        Image(systemName: "trophy")
                            .font(.title2)
                        Text("Leaderboard")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
        .onAppear {
            // Reset quiz state when returning to main menu
            quizGame.resetQuizState()
        }
    }
}

#Preview {
    ContentView()
}
