import SwiftUI

struct CustomKeyboardView: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    
    let keys: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            handleKeyPress(key)
                        }) {
                            Text(key)
                                .font(.system(size: 20))
                                .frame(width: key == "⌫" ? 60 : 30, height: 40)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            HStack {
                Button(action: {
                    isVisible = false
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 60, height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    text += " "
                }) {
                    Text("Space")
                        .font(.system(size: 16))
                        .frame(width: 100, height: 40)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "⌫" {
            if !text.isEmpty {
                text.removeLast()
            }
        } else {
            text += key
        }
    }
}

struct SweetpadView: View {
    @State private var text: String = ""
    @State private var isKeyboardVisible: Bool = false
    
    var body: some View {
        VStack {
            TextField("Enter food name", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                isKeyboardVisible.toggle()
            }) {
                Text("Show Keyboard")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if isKeyboardVisible {
                CustomKeyboardView(text: $text, isVisible: $isKeyboardVisible)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isKeyboardVisible)
            }
        }
    }
}

#Preview {
    SweetpadView()
} 