//
//  QuickNoteHistory.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import SwiftUI
import SakuraExtension
import WaterfallGrid
import SwiftUIIntrospect

import RealmSwift
import Realm

struct Note {
    var id = UUID().uuidString
    var content: String
    var createdDate: Date
    var color: NoteColor = .yellow
    
    enum NoteColor: CaseIterable {
        static var allCases: [Note.NoteColor] = [.yellow, .red, .blue]
        
        case yellow
        case red
        case blue
        case custom(String)
        
        var swiftUIColor: Color {
            switch self {
            case .yellow: Color("good")
            case .red: Color("Error")
            case .blue: Color("Information")
            case .custom(let code): Color(hex: code)
            }
        }
        
        var value: String {
            return switch self {
            case .yellow: "yellow"
            case .red: "red"
            case .blue: "blue"
            case .custom(let code): code
            }
        }
    }
    
    init() {
        self.id = ""
        self.content = ""
        self.createdDate = Date()
    }
    
    init(from rlm: RlmNote) {
        self.id = rlm.id.stringValue
        self.content = rlm.content
        self.createdDate = rlm.createdDate
        
        switch rlm.color {
        case "yellow":
            self.color = .yellow
        case "red":
            self.color = .red
        case "blue":
            self.color = .blue
        default:
            self.color = .custom(rlm.color)
        }
        
    }
}

class RlmNote: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var createdDate: Date = Date()
    @Persisted var content: String!
    @Persisted var color: String!
}

extension Notification.Name {
    static let updateNote = Notification.Name("updateNote")
}

final class NoteDAO: RealmDao {
    static let shared = NoteDAO()
    
    @discardableResult
    func addObject(note: Note, content: String, color: Note.NoteColor?) -> Note? {
        let object = RlmNote()
        object.color = note.color.value
        object.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let objectID = try? ObjectId(string: note.id),
              let oldObject = try? self.objectWithPrimaryKey(type: RlmNote.self, key: objectID) {
            object.id = objectID
            object.createdDate = oldObject.createdDate
        } else {
            object.id = .generate()
            object.createdDate = Date()
        }
        
        if let color {
            object.color = color.value
        }
        
        do {
            try self.addObjectAndUpdate(object)
            print("thêm note thanh cong: \(content)")
            NotificationCenter.default.post(name: .updateNote, object: nil)
            return getNote(id: object.id.stringValue)
        } catch {
            print("❌ Lỗi thêm note: \(error)")
            return nil
        }
    }
    
    func getNote(id: String) -> Note? {
        guard let objectID = try? ObjectId(string: id),
              let object = try? self.objectWithPrimaryKey(type: RlmNote.self, key: objectID) else {
            return nil
        }
        
        return Note(from: object)
    }
    
    func deleteObject(id: String) {
        guard let object = try? self.objectWithPrimaryKey(type: RlmNote.self, key: ObjectId(string: id)) else {
            return
        }
                
        do {
            try self.deleteObject(object)
            NotificationCenter.default.post(name: .updateNote, object: nil)
        } catch {
            print("❌ Lỗi xoá mood record: \(error)")
        }
    }
    
    func getAll() -> [Note] {
        guard let listItem = try? self.objects(type: RlmNote.self) else {
            return []
        }
        
        return listItem.map({ Note(from: $0) })
    }
}

class QuickNoteHistoryViewModel: ObservableObject {
    @Published var noteGroup: [Date: [Note]] = [:]
    @Published var currentNote: Note? {
        didSet {
            if currentNote == nil {
                getData()
            }
        }
    }
    
    init() {
        getData()
    }
    
    @objc func getData() {
        print("Update notes")
        let notes = NoteDAO.shared.getAll()
        noteGroup = Dictionary(grouping: notes) { note in
            Calendar.current.startOfDay(for: note.createdDate)
        }
        
        objectWillChange.send()
    }
}

// MARK: - History View
struct QuickNoteHistory: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = QuickNoteHistoryViewModel()
    
    @ViewBuilder
    var body: some View {
        if let currentNote = viewModel.currentNote {
            NoteView(currentNote: $viewModel.currentNote,
                     note: currentNote,
                     open: true)
        } else {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("ic_back")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foreColor(mainColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foreColor(mainColor)
                        .onTapGesture {
                            withAnimation {
                                viewModel.currentNote = Note()
                            }
                        }
                }
                .overlay(
                    Text("Quick Note")
                        .gilroyBold(16)
                        .foreColor(mainColor)
                )
                .frame(height: 56)
                .padding(.horizontal, 20)
                
                if viewModel.noteGroup.isEmpty {
                    Spacer().frame(height: 100)
                    Image("ic_empty")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    Text("You haven't logged any notes yet.")
                        .gilroyRegular(16)
                        .foregroundStyle(.gray)
                        .padding(.top, 5)
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        VStack {
                            ForEach(viewModel.noteGroup.keys.sorted(by: { $0 >= $1 }), id: \.hashValue) { date in
                                if let notes = viewModel.noteGroup[date]?.sorted(by: { $0.createdDate >= $1.createdDate }) {
                                    HStack {
                                        Text(date.format("dd MMMM yyyy"))
                                            .gilroyBold(15)
                                            .foreColor(mainColor)
                                        Spacer()
                                    }
                                    .frame(height: 25)
                                    .padding(.horizontal, 20)
                                    
                                    if notes.count == 1 {
                                        HStack(alignment: .top, spacing: 0) {
                                            item(note: notes[0])
                                            Spacer()
                                            item(note: notes[0])
                                                .hidden()
                                        }.padding(.horizontal, 20)
                                    } else if notes.count == 2 {
                                        HStack(alignment: .top, spacing: 0) {
                                            item(note: notes[0])
                                            Spacer()
                                            item(note: notes[1])
                                        }.padding(.horizontal, 20)
                                    } else {
                                        WaterfallGrid(notes, id: \.id) { note in
                                            item(note: note)
                                        }
                                        .scrollOptions(direction: .vertical)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(backgroundColor.ignoresSafeArea())
        }
    }
    
    
    @ViewBuilder
    func item(note: Note) -> some View {
        NoteView(currentNote: $viewModel.currentNote, note: note, open: false)
            .onTapGesture {
                withAnimation {
                    viewModel.currentNote = note
                }
            }
    }
    
    var backgroundColor: Color {
        return User.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return User.isTurnDarkMode ? .white : .black
    }
}

// MARK: - Note
struct NoteView: View {
    @StateObject var viewModel: NoteViewModel
    @Binding var currentNote: Note?
    @State var needPresentKeyboard: Bool = false
    @State private var showAlert = false
    
    var open: Bool
    
    var width: CGFloat {
        (UIScreen.main.bounds.width - 20 * 2 - 20) / 2
    }
    
    init(currentNote: Binding<Note?>, note: Note, open: Bool) {
        self._viewModel = .init(wrappedValue: NoteViewModel(note: note))
        self._currentNote = currentNote
        
        self.open = open
        UITextView.appearance().backgroundColor = .clear
    }
    
    @ViewBuilder
    var body: some View {
        if open {
            VStack {
                HStack {
                    if !viewModel.isEditing {
                        Image(systemName: "multiply")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    viewModel.deleteIfNeed()
                                    withAnimation {
                                        currentNote = nil
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                    
                    if viewModel.isEditing {
                        Text("Save")
                            .gilroyBold(16)
                            .onTapGesture {
                                viewModel.done()
                            }
                    } else {
                        Button(action: {
                            self.showAlert = true
                        }, label: {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.black)
                        })
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 56)
                
                TextEditor(text: $viewModel.currentText)
                    .transparentScrolling()
                    .gilroyRegular(16)
                    .padding(.horizontal, 20)
                    .onChange(of: viewModel.currentText, perform: { _ in
                        viewModel.isEditing = true
                    })
            }
            .background(color.ignoresSafeArea())
            .onAppear {
                self.needPresentKeyboard = viewModel.currentText.isEmpty
            }
            .confirmationDialog("Choose an option", isPresented: $showAlert, titleVisibility: .visible) {
                Button("Change Note Background Color") {
                    showColorPicker = true
                }
                
                Button("Delete") {
                    viewModel.delete()
                    withAnimation {
                        currentNote = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerSheet(selectedColor: .init {
                    return viewModel.note.color
                } set: { newValue in
                    self.viewModel.selectColor(newValue)
                }, currentColor: viewModel.note.color)
            }
        } else {
            Text(viewModel.note.content)
                .gilroyRegular(width / 13)
                .padding(10)
                .frame(maxHeight: 100)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: width, alignment: .topLeading)
                .background(color)
                .cornerRadius(5)
        }
    }
    
    @State private var showColorPicker = false
    
    var color: Color {
        return viewModel.note.color.swiftUIColor
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: Note.NoteColor
    @Environment(\.dismiss) var dismiss
    @State var currentColor: Note.NoteColor
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ColorPicker("Custom Color", selection: .init(get: {
                    return currentColor.swiftUIColor
                }, set: { newColor in
                    if isAlmostBlack(color: newColor) {
                        showAlert = true
                    } else {
                        currentColor = .custom(newColor.toHex() ?? "")
                    }
                }), supportsOpacity: false)
                
                .font(.custom("Gilroy-Regular", size: 16))
                
                Text("Default Color")
                    .gilroySemiBold(20)
                    .padding(.vertical, 15)
                LazyVGrid(columns: [.init(.adaptive(minimum: 50))]) {
                    ForEach(Note.NoteColor.allCases, id: \.value) { color in
                        color.swiftUIColor.frame(width: 50, height: 50).cornerRadius(5)
                            .onTapGesture {
                                currentColor = color
                            }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Color Picker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        selectedColor = currentColor
                        dismiss()
                    }
                }
            }
            .alert("The color is too dark! Please choose a lighter color", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    func isAlmostBlack(color: Color) -> Bool {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // Định nghĩa "gần như đen" nếu R, G, B đều nhỏ hơn 0.1
        return r < 0.4 && g < 0.4 && b < 0.4
    }
}


public extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

class NoteViewModel: NSObject, ObservableObject {
    @Published var note: Note
    @Published var isEditing: Bool
    @Published var currentText: String
   
    init(note: Note) {
        self.note = note
        self.currentText = note.content
        self.isEditing = false
    }
    
    func done() {
        save()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        self.isEditing = false
    }
    
    func save() {
        DispatchQueue.main.async {
            if self.currentText.isEmpty {
                self.delete()
            } else {
                if let note = NoteDAO.shared.addObject(note: self.note, content: self.currentText, color: nil) {
                    print("new text: \(note.content)")
                    self.note = note
                }
            }
        }
    }
    
    func selectColor(_ color: Note.NoteColor) {
        if let note = NoteDAO.shared.addObject(note: self.note, content: self.currentText, color: color) {
            print("new text: \(note.content)")
            self.note = note
        }
    }
    
    func delete() {
        NoteDAO.shared.deleteObject(id: note.id)
    }
    
    func deleteIfNeed() {
        if currentText.isEmpty {
            delete()
        }
    }
}

#Preview {
    QuickNoteHistory()
}
