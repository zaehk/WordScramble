//
//  ContentView.swift
//  WordScramble
//
//  Created by Borja Saez de Guinoa Vilaplana on 3/7/21.
//

import SwiftUI

struct WordView: View {
    
    var word: String
    var wordBackgroundColor: Color
    var borderColor: Color
    var wordSize: CGFloat
    
    var body: some View {
        HStack {
            ForEach(word.uppercased().map({String($0)}), id: \.self) { letter in
                Text(letter)
                    .fontWeight(.bold)
                    .frame(width: wordSize, height: wordSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .background(wordBackgroundColor)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(borderColor, lineWidth: 1))
                    .shadow(radius: 3)
                
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
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                WordView(word: rootWord, wordBackgroundColor: Color.init(red: 253/255, green: 209/255, blue: 113/255) , borderColor: Color.init(red: 166/255, green: 143/255, blue: 100/255), wordSize: 40)
                
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    WordView(word: $0, wordBackgroundColor: Color.init(UIColor.init(red: 238/255, green: 237/255, blue: 218/255, alpha: 1)), borderColor: .black, wordSize: 30)
                }
            }
            .padding()
            .navigationTitle("WordScramble")
            .navigationBarItems(trailing:  )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func startGame() {
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            fatalError("Could not load start.txt from bundle.")
            return
        }
        if let startWords = try? String(contentsOf: startWordsURL) {
            let allWords = startWords.components(separatedBy: "\n")
            rootWord = allWords.randomElement() ?? "silkworm"
            
            return
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //not empty
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
