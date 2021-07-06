//
//  ContentView.swift
//  WordScramble
//
//  Created by Borja Saez de Guinoa Vilaplana on 3/7/21.
//

import SwiftUI


struct WordView: View {
    
    var word: String
    @Binding var shuffleAmount: Double
    @State var shouldBounce: Bool
    
    var wordColors: [Color]
    var borderColor: Color
    var wordSize: CGFloat
    
    var body: some View {
        HStack {
            ForEach(Array(word.enumerated()), id: \.offset) { character in
                
                let animationDelay = Double(character.offset) / 40
                
                 Text(String(character.element).uppercased())
                    .fontWeight(.bold)
                    .frame(width: wordSize, height: wordSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    .background(LinearGradient(gradient: Gradient(colors: wordColors), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(borderColor, lineWidth: 1))
                    .shadow(radius: 3)
                    .scaleEffect(shouldBounce ? 0.3 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 100, damping: 7).delay(animationDelay))
                    .rotation3DEffect(
                        .degrees(shuffleAmount),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .animation(Animation.default.delay(animationDelay))
                
                
            }.onAppear{
                shouldBounce = false
            }
        }
    }
    
}

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var shuffleAmount: Double = 0
    @State private var allWords : [String] = []
    @State private var totalScore: Int = 0
    
    let rootWordColors : [Color] = [
        Color.init(red: 242/255, green: 191/255, blue: 106/255),
        Color.init(red: 244/255, green: 215/255, blue: 140/255)
    ]
    
    let answerWordColors: [Color] = [
        Color.init(red: 242/255, green: 250/255, blue: 248/255),
        Color.init(red: 236/255, green: 232/255, blue: 220/255)
    ]
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                WordView(word: rootWord,  shuffleAmount: $shuffleAmount, shouldBounce: false,  wordColors: rootWordColors , borderColor: Color.init(red: 166/255, green: 143/255, blue: 100/255), wordSize: 40)
                
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                        .foregroundColor(.orange)
                    WordView(word: $0, shuffleAmount: $shuffleAmount , shouldBounce: true, wordColors: answerWordColors , borderColor: .black, wordSize: 30)
                }
                HStack{
                    Text("Total Score: \(totalScore)")
                }
            }
            .padding()
            .navigationTitle("WordScramble")
            .navigationBarItems(trailing: Button(action: resetRootword, label: {
                Image(systemName: "pencil.and.outline").foregroundColor(.orange)
            }))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func startGame() {
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            fatalError("Could not load start.txt from bundle.")
        }
        if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                newWord.removeAll()
            return
        }
    }
    
    func resetRootword() {
        rootWord = allWords.randomElement() ?? "silkworm"
        shuffleAmount += 360
        newWord.removeAll()
        usedWords.removeAll()
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognize", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        
        withAnimation(.linear) {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        totalScore += answer.count
        
    }
    
    //MARK: -Word checks
    
    func isOriginal(word: String)->Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    //MARK: -Show error alert
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
