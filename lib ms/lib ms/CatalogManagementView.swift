import SwiftUI
import CoreData
import PhotosUI

// Catalog Management View
struct CatalogManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = CatalogViewModel()
    @State private var showingAddBook = false
    @State private var showingEditBook = false
    @State private var bookToEdit: Book?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Manage Catalog")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddBook = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                                .overlay(
                                    Circle()
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                )
                        }
                        .accessibilityLabel("Add New Book")
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Quick Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Books",
                                value: "\(viewModel.totalBooks)",
                                icon: "book.fill",
                                color: .blue,
                                isLoaded: true
                            )
                            
                            StatCard(
                                title: "Available Books",
                                value: "\(viewModel.availableBooks)",
                                icon: "checkmark.circle.fill",
                                color: .green,
                                isLoaded: true
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Sections
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            InventoryCard(
                                title: "Authors",
                                value: "\(viewModel.authors.count)",
                                subtitle: "",
                                color: .blue,
                                isLoaded: true
                            )
                            .onTapGesture {
                                // Navigate to Authors list (placeholder)
                            }
                            
                            InventoryCard(
                                title: "Genres",
                                value: "\(viewModel.genres.count)",
                                subtitle: "",
                                color: .blue,
                                isLoaded: true
                            )
                            .onTapGesture {
                                // Navigate to Genres list (placeholder)
                            }
                        }
                        .padding(.horizontal)
                        
                        InventoryCard(
                            title: "Books Inventory",
                            value: "\(viewModel.books.count)",
                            subtitle: "",
                            color: .indigo,
                            isLoaded: true
                        )
                        .padding(.horizontal)
                        .onTapGesture {
                            // Navigate to full inventory (placeholder)
                        }
                        
                        // Books Inventory List
                        VStack(spacing: 12) {
                            ForEach(viewModel.books) { book in
                                BookItemView(book: book, viewContext: viewContext, showingEditBook: $showingEditBook, bookToEdit: $bookToEdit, onDelete: {
                                    viewModel.loadData(context: viewContext)
                                })
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 60) // Space for tab bar
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddBook, onDismiss: {
                viewModel.loadData(context: viewContext)
            }) {
                AddBookView()
            }
            .sheet(isPresented: $showingEditBook, onDismiss: {
                viewModel.loadData(context: viewContext)
            }) {
                if let book = bookToEdit {
                    EditBookView(book: book)
                }
            }
            .onAppear {
                print("CatalogManagementView appeared")
                print("Managed Object Context: \(viewContext)")
                print("Document Directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "Not found")")
                viewModel.loadData(context: viewContext)
                generateSampleData(context: viewContext)
            }
        }
    }
}

// Book Item View
struct BookItemView: View {
    let book: Book
    let viewContext: NSManagedObjectContext
    @Binding var showingEditBook: Bool
    @Binding var bookToEdit: Book?
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "book")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                bookToEdit = book
                showingEditBook = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button(action: {
                softDelete(book: book)
                onDelete()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button(action: {
                let favorite = book.isFavorite
                book.isFavorite = !favorite
                try? viewContext.save()
            }) {
                Image(systemName: (book.isFavorite) ? "heart.fill" : "heart")
                    .foregroundColor((book.isFavorite) ? .red : .gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func softDelete(book: Book) {
        book.status = "inactive"
        try? viewContext.save()
    }
}

// ViewModel for Catalog
class CatalogViewModel: ObservableObject {
    @Published var totalBooks: Int = 0
    @Published var availableBooks: Int = 0
    @Published var authors: [String] = []
    @Published var genres: [String] = []
    @Published var books: [Book] = []
    
    func loadData(context: NSManagedObjectContext) {
        // Total Books
        let totalRequest: NSFetchRequest<Book> = Book.fetchRequest()
        totalRequest.predicate = NSPredicate(format: "status != %@", "inactive")
        totalBooks = (try? context.count(for: totalRequest)) ?? 0
        
        // Available Books
        let availableRequest: NSFetchRequest<Book> = Book.fetchRequest()
        availableRequest.predicate = NSPredicate(format: "status == %@", "available")
        availableBooks = (try? context.count(for: availableRequest)) ?? 0
        
        // Authors (Unique from Books)
        let authorRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Book")
        authorRequest.predicate = NSPredicate(format: "status != %@", "inactive")
        authorRequest.propertiesToFetch = ["author"]
        authorRequest.returnsDistinctResults = true
        authorRequest.resultType = .dictionaryResultType
        if let results = try? context.fetch(authorRequest) as? [[String: Any]] {
            authors = results.compactMap { $0["author"] as? String }.sorted()
        }
        
        // Genres (Unique from Books)
        let genreRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Book")
        genreRequest.predicate = NSPredicate(format: "status != %@", "inactive")
        genreRequest.propertiesToFetch = ["genre"]
        genreRequest.returnsDistinctResults = true
        genreRequest.resultType = .dictionaryResultType
        if let results = try? context.fetch(genreRequest) as? [[String: Any]] {
            genres = results.compactMap { $0["genre"] as? String }.sorted()
        }
        
        // Books
        let booksRequest: NSFetchRequest<Book> = Book.fetchRequest()
        booksRequest.predicate = NSPredicate(format: "status != %@", "inactive")
        booksRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        books = (try? context.fetch(booksRequest)) ?? []
    }
}

// Add Book View
struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title = ""
    @State private var author = ""
    @State private var selectedGenre = "Fiction"
    @State private var isbn = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    private let genres = ["Fiction", "Mystery", "Science Fiction", "Biography", "Non-Fiction", "Fantasy", "History"]
    
    #if canImport(PhotosUI)
    @State private var pickerItem: PhotosPickerItem?
    #endif
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(genres, id: \.self) { genre in
                            Text(genre)
                        }
                    }
                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numberPad)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
                
                Section(header: Text("Cover Image")) {
                    #if canImport(PhotosUI)
                    PhotosPicker(
                        selection: $pickerItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            HStack {
                                Text(image == nil ? "Select Cover Image" : "Change Cover Image")
                                Spacer()
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                        .shadow(radius: 2)
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .frame(width: 80, height: 120)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .onChange(of: pickerItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    // Limit image size to 500KB
                                    if let compressedData = uiImage.jpegData(compressionQuality: 0.5),
                                       compressedData.count <= 500 * 1024 {
                                        image = uiImage
                                        print("Image selected successfully, size: \(compressedData.count) bytes")
                                    } else {
                                        print("Image too large, skipping cover image")
                                        image = nil
                                    }
                                } else {
                                    print("Failed to load image from PhotosPicker")
                                    image = nil
                                }
                            }
                        }
                    #else
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Text(image == nil ? "Select Cover Image" : "Change Cover Image")
                            Spacer()
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .shadow(radius: 2)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $image)
                    }
                    #endif
                }
            }
            .navigationTitle("Add New Book")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        saveBook()
                    }) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving || title.isEmpty || author.isEmpty || isbn.isEmpty)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    isSaving = false
                    dismiss()
                })
            }
        }
    }
    
    private func validateISBN(_ isbn: String) -> Bool {
        let isbnCleaned = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        print("Validating ISBN: \(isbnCleaned)")
        
        // Simplified validation for testing: Accept any 10 or 13 digit ISBN
        if isbnCleaned.count == 10 || isbnCleaned.count == 13 {
            return true
        }
        
        alertMessage = "ISBN must be 10 or 13 digits (numbers only). Example: 1234567890 or 1234567890123"
        showingAlert = true
        return false
    }
    
    private func saveBook() {
        isSaving = true
        print("Starting saveBook process...")
        
        let isbnRequest: NSFetchRequest<Book> = Book.fetchRequest()
        isbnRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        // Perform save operation in the background
        viewContext.perform {
            do {
                print("Checking for existing ISBN: \(self.isbn)")
                let existingBooks = try self.viewContext.fetch(isbnRequest)
                if !existingBooks.isEmpty {
                    DispatchQueue.main.async {
                        self.alertMessage = "ISBN \(self.isbn) already exists. Please use a unique ISBN."
                        self.showingAlert = true
                        self.isSaving = false
                    }
                    return
                }
                
                if self.title.isEmpty || self.author.isEmpty || self.isbn.isEmpty {
                    DispatchQueue.main.async {
                        self.alertMessage = "Title, Author, and ISBN are required fields."
                        self.showingAlert = true
                        self.isSaving = false
                    }
                    return
                }
                
                if !self.validateISBN(self.isbn) {
                    DispatchQueue.main.async {
                        self.isSaving = false
                    }
                    return
                }
                
                print("Creating new book with title: \(self.title), author: \(self.author), isbn: \(self.isbn)")
                let newBook = Book(context: self.viewContext)
                newBook.id = UUID()
                newBook.title = self.title
                newBook.author = self.author
                newBook.genre = self.selectedGenre
                newBook.isbn = self.isbn
                newBook.bookDescription = self.description.isEmpty ? nil : self.description
                newBook.status = "available"
                newBook.createdAt = Date()
                newBook.isFavorite = false
                
                // Handle cover image safely
                if let image = self.image, let imageData = image.jpegData(compressionQuality: 0.5) {
                    print("Cover image data size: \(imageData.count) bytes")
                    newBook.coverImage = imageData
                } else {
                    print("No cover image or failed to convert to JPEG data")
                    newBook.coverImage = Data()
                }
                
                print("Saving book to Core Data...")
                try self.viewContext.save()
                print("Book saved successfully: \(newBook.title)")
                
                // Verify the book was saved
                let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "isbn == %@", self.isbn)
                let savedBooks = try self.viewContext.fetch(fetchRequest)
                if savedBooks.isEmpty {
                    print("Verification failed: Book not found in database after save")
                } else {
                    print("Verification successful: Book found in database")
                }
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.dismiss()
                }
                
            } catch {
                print("Failed to save book: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to save book: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isSaving = false
                }
            }
        }
    }
}

// Edit Book View
struct EditBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title: String
    @State private var author: String
    @State private var selectedGenre: String
    @State private var isbn: String
    @State private var description: String
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    private let genres = ["Fiction", "Mystery", "Science Fiction", "Biography", "Non-Fiction", "Fantasy", "History"]
    private let book: Book
    private let originalISBN: String
    
    #if canImport(PhotosUI)
    @State private var pickerItem: PhotosPickerItem?
    #endif
    
    init(book: Book) {
        self.book = book
        self.originalISBN = book.isbn
        _title = State(initialValue: book.title)
        _author = State(initialValue: book.author)
        _selectedGenre = State(initialValue: book.genre)
        _isbn = State(initialValue: book.isbn)
        _description = State(initialValue: book.description)
        if let uiImage = UIImage(data: book.coverImage) {
            _image = State(initialValue: uiImage)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(genres, id: \.self) { genre in
                            Text(genre)
                        }
                    }
                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numberPad)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
                
                Section(header: Text("Cover Image")) {
                    #if canImport(PhotosUI)
                    PhotosPicker(
                        selection: $pickerItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            HStack {
                                Text(image == nil ? "Select Cover Image" : "Change Cover Image")
                                Spacer()
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                        .shadow(radius: 2)
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .frame(width: 80, height: 120)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .onChange(of: pickerItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    // Limit image size to 500KB
                                    if let compressedData = uiImage.jpegData(compressionQuality: 0.5),
                                       compressedData.count <= 500 * 1024 {
                                        image = uiImage
                                        print("Image selected successfully, size: \(compressedData.count) bytes")
                                    } else {
                                        print("Image too large, skipping cover image")
                                        image = nil
                                    }
                                } else {
                                    print("Failed to load image from PhotosPicker")
                                    image = nil
                                }
                            }
                        }
                    #else
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Text(image == nil ? "Select Cover Image" : "Change Cover Image")
                            Spacer()
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .shadow(radius: 2)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $image)
                    }
                    #endif
                }
            }
            .navigationTitle("Edit Book")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        saveBook()
                    }) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving || title.isEmpty || author.isEmpty || isbn.isEmpty)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    isSaving = false
                    dismiss()
                })
            }
        }
    }
    
    private func validateISBN(_ isbn: String) -> Bool {
        let isbnCleaned = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        print("Validating ISBN: \(isbnCleaned)")
        
        // Simplified validation for testing: Accept any 10 or 13 digit ISBN
        if isbnCleaned.count == 10 || isbnCleaned.count == 13 {
            return true
        }
        
        alertMessage = "ISBN must be 10 or 13 digits (numbers only). Example: 1234567890 or 1234567890123"
        showingAlert = true
        return false
    }
    
    private func saveBook() {
        isSaving = true
        print("Starting saveBook process for editing...")
        
        let isbnRequest: NSFetchRequest<Book> = Book.fetchRequest()
        isbnRequest.predicate = NSPredicate(format: "isbn == %@ AND id != %@", isbn, book.id.uuidString)
        
        viewContext.perform {
            do {
                print("Checking for existing ISBN: \(self.isbn)")
                let existingBooks = try self.viewContext.fetch(isbnRequest)
                if !existingBooks.isEmpty {
                    DispatchQueue.main.async {
                        self.alertMessage = "ISBN \(self.isbn) already exists. Please use a unique ISBN."
                        self.showingAlert = true
                        self.isSaving = false
                    }
                    return
                }
                
                if self.title.isEmpty || self.author.isEmpty || self.isbn.isEmpty {
                    DispatchQueue.main.async {
                        self.alertMessage = "Title, Author, and ISBN are required fields."
                        self.showingAlert = true
                        self.isSaving = false
                    }
                    return
                }
                
                if !self.validateISBN(self.isbn) {
                    DispatchQueue.main.async {
                        self.isSaving = false
                    }
                    return
                }
                
                print("Updating book with title: \(self.title), author: \(self.author), isbn: \(self.isbn)")
                self.book.title = self.title
                self.book.author = self.author
                self.book.genre = self.selectedGenre
                self.book.isbn = self.isbn
                self.book.bookDescription = self.description.isEmpty ? nil : self.description
                
                // Handle cover image safely
                if let image = self.image, let imageData = image.jpegData(compressionQuality: 0.5) {
                    print("Cover image data size: \(imageData.count) bytes")
                    self.book.coverImage = imageData
                } else {
                    print("No cover image or failed to convert to JPEG data")
                    self.book.coverImage = Data()
                }
                
                print("Saving updated book to Core Data...")
                try self.viewContext.save()
                print("Book updated successfully: \(self.book.title)")
                
                // Verify the book was updated
                let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "isbn == %@", self.isbn)
                let savedBooks = try self.viewContext.fetch(fetchRequest)
                if savedBooks.isEmpty {
                    print("Verification failed: Updated book not found in database")
                } else {
                    print("Verification successful: Updated book found in database")
                }
                
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.dismiss()
                }
                
            } catch {
                print("Failed to update book: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to save book: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isSaving = false
                }
            }
        }
    }
}

// Image Picker for iOS 15 (Fallback)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Sample Data Generation
func generateSampleData(context: NSManagedObjectContext) {
    let bookRequest: NSFetchRequest<Book> = Book.fetchRequest()
    let count = (try? context.count(for: bookRequest)) ?? 0
    print("Existing books count: \(count)")
    if count > 0 { return }
    
    for i in 1...50 {
        let book = Book(context: context)
        book.id = UUID()
        book.title = "Book Title \(i)"
        book.author = "Author \(i)"
        book.genre = ["Fiction", "Non-Fiction", "Science"].randomElement() ?? "Fiction"
        book.isbn = "ISBN\(String(format: "%010d", i))" // Generate valid 10-digit ISBN-like string
        book.bookDescription = "Description for book \(i)"
        book.status = i % 5 == 0 ? "borrowed" : "available"
        book.createdAt = Calendar.current.date(byAdding: .day, value: -i % 30, to: Date())!
        book.isFavorite = Bool.random()
        book.coverImage = Data()
    }
    
    do {
        try context.save()
        print("Sample data generated and saved successfully.")
    } catch {
        print("Failed to save sample data: \(error.localizedDescription)")
    }
}

struct CatalogManagementView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
