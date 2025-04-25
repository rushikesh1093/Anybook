import SwiftUI
import CoreData

// Main Tab View for Librarian
struct LibrarianInterface: View {
    var body: some View {
        TabView {
            LibrarianDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            CatalogManagementView()
                .tabItem {
                    Label("Catalog", systemImage: "books.vertical")
                }
            
            CirculationManagementView()
                .tabItem {
                    Label("Circulation", systemImage: "arrow.left.arrow.right")
                }
        }
        .accentColor(.accentColor)
    }
}

// Dashboard View
struct LibrarianDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingProfile = false
    @State private var isLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.greetingMessage)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingProfile = true }) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.blue)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        .accessibilityLabel("Profile")
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(viewModel.greetingMessage), \(viewModel.currentDate)")
                    
                    Spacer()
                    
                    // Quick Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Main stats grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Books Issued",
                                value: "\(viewModel.booksIssued)",
                                icon: "book.fill",
                                color: .blue,
                                isLoaded: isLoaded
                            )
                            
                            StatCard(
                                title: "Active Members",
                                value: "\(viewModel.membershipCount)",
                                icon: "person.3.fill",
                                color: .green,
                                isLoaded: isLoaded
                            )
                            
                            StatCard(
                                title: "Latest Additions",
                                value: "\(viewModel.latestAdditions)",
                                icon: "plus.circle.fill",
                                color: .purple,
                                isLoaded: isLoaded
                            )
                            
                            StatCard(
                                title: "Overdue Books",
                                value: "\(viewModel.overdueBooks)",
                                icon: "exclamationmark.circle.fill",
                                color: .red,
                                isLoaded: isLoaded
                            )
                        }
                        
                        // Library inventory row
                        HStack(spacing: 16) {
                            InventoryCard(
                                title: "Total Collection",
                                value: "\(viewModel.totalBooks)",
                                subtitle: "books in database",
                                color: .indigo,
                                isLoaded: isLoaded
                            )
                            
                            InventoryCard(
                                title: "Available Now",
                                value: "\(viewModel.availableBooks)",
                                subtitle: "ready for checkout",
                                color: .teal,
                                isLoaded: isLoaded
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ActionCard(
                                    title: "Add New Book",
                                    description: "Add a book to the catalog",
                                    icon: "plus.circle.fill",
                                    color: .blue,
                                    isLoaded: isLoaded
                                ) {
                                    // Navigate to AddBookView (placeholder)
                                }
                                
                                ActionCard(
                                    title: "Membership Requests",
                                    description: "Review new member requests",
                                    icon: "person.crop.circle.badge.plus",
                                    color: .green,
                                    isLoaded: isLoaded
                                ) {
                                    // Navigate to Membership Requests (placeholder)
                                }
                                
                                ActionCard(
                                    title: "Member Queries",
                                    description: "View user inquiries",
                                    icon: "questionmark.circle.fill",
                                    color: .orange,
                                    isLoaded: isLoaded
                                ) {
                                    // Navigate to Member Queries (placeholder)
                                }
                                
                                ActionCard(
                                    title: "Overdue Books",
                                    description: "Handle late returns",
                                    icon: "exclamationmark.circle.fill",
                                    color: .red,
                                    isLoaded: isLoaded
                                ) {
                                    // Navigate to Overdue Books (placeholder)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .onAppear {
                viewModel.loadStats(context: viewContext)
                generateSampleData(context: viewContext)
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLoaded = true
                }
            }
        }
    }
}

// Profile View
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = UserDefaults.standard.string(forKey: "librarianName") ?? "Alex"
    @State private var email: String = UserDefaults.standard.string(forKey: "librarianEmail") ?? "alex@example.com"
    @State private var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("App Settings")) {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.set(name, forKey: "librarianName")
                        UserDefaults.standard.set(email, forKey: "librarianEmail")
                        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// ViewModel for Dashboard
class DashboardViewModel: ObservableObject {
    @Published var greetingMessage: String = ""
    @Published var currentDate: String = ""
    @Published var booksIssued: Int = 0
    @Published var membershipCount: Int = 0
    @Published var latestAdditions: Int = 0
    @Published var totalBooks: Int = 0
    @Published var availableBooks: Int = 0
    @Published var overdueBooks: Int = 0
    
    init() {
        updateGreetingAndDate()
    }
    
    private func updateGreetingAndDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        currentDate = dateFormatter.string(from: Date())
        
        let hour = Calendar.current.component(.hour, from: Date())
        let name = UserDefaults.standard.string(forKey: "librarianName") ?? "Alex"
        greetingMessage = hour < 12 ? "Good Morning, \(name)" : hour < 17 ? "Good Afternoon, \(name)" : "Good Evening, \(name)"
    }
    
    func loadStats(context: NSManagedObjectContext) {
        // Books Issued (Borrows with no return date)
        let borrowRequest: NSFetchRequest<Borrow> = Borrow.fetchRequest()
        borrowRequest.predicate = NSPredicate(format: "returnDate == nil")
        booksIssued = (try? context.count(for: borrowRequest)) ?? 0
        
        // Membership Count (Users with role "member")
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.predicate = NSPredicate(format: "role == %@", "member")
        membershipCount = (try? context.count(for: userRequest)) ?? 0
        
        // Latest Additions (Books added in last 30 days)
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let bookRequest: NSFetchRequest<Book> = Book.fetchRequest()
        bookRequest.predicate = NSPredicate(format: "createdAt >= %@", thirtyDaysAgo as NSDate)
        latestAdditions = (try? context.count(for: bookRequest)) ?? 0
        
        // Total Books
        let totalBookRequest: NSFetchRequest<Book> = Book.fetchRequest()
        totalBooks = (try? context.count(for: totalBookRequest)) ?? 0
        
        // Available Books
        let availableBookRequest: NSFetchRequest<Book> = Book.fetchRequest()
        availableBookRequest.predicate = NSPredicate(format: "status == %@", "available")
        availableBooks = (try? context.count(for: availableBookRequest)) ?? 0
        
        // Overdue Books
        let overdueRequest: NSFetchRequest<Borrow> = Borrow.fetchRequest()
        overdueRequest.predicate = NSPredicate(format: "dueDate < %@ AND returnDate == nil", Date() as NSDate)
        overdueBooks = (try? context.count(for: overdueRequest)) ?? 0
    }
}

struct CirculationManagementView: View {
    var body: some View {
        NavigationView {
            Text("Circulation Management")
                .navigationTitle("Circulation")
        }
    }
}

// Sample Data Generation (For Testing)
//func generateSampleData(context: NSManagedObjectContext) {
//    // Check if data already exists
//    let bookRequest: NSFetchRequest<Book> = Book.fetchRequest()
//    if (try? context.count(for: bookRequest)) ?? 0 > 0 { return }
//    
//    // Add Sample Books
//    for i in 1...50 {
//        let book = Book(context: context)
//        book.id = UUID()
//        book.title = "Book Title \(i)"
//        book.author = "Author \(i)"
//        book.genre = ["Fiction", "Non-Fiction", "Science"].randomElement()!
//        book.isbn = "ISBN\(i)"
//        book.bookDescription = "Description for book \(i)"
//        book.status = i % 5 == 0 ? "borrowed" : "available"
//        book.createdAt = Calendar.current.date(byAdding: .day, value: -i % 30, to: Date())
//        book.coverImage = Data()
//    }
//    
//    // Add Sample Users
//    for i in 1...20 {
//        let user = User(context: context)
//        user.id = UUID()
//        user.name = "Member \(i)"
//        user.email = "member\(i)@example.com"
//        user.role = "member"
//        user.isMember = true
//    }
//    
//    // Add Sample Borrows
//    for i in 1...15 {
//        let borrow = Borrow(context: context)
//        borrow.id = UUID()
//        borrow.bookID = UUID() // Simplified; link to actual book in production
//        borrow.userID = UUID() // Simplified; link to actual user
//        borrow.borrowDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
//        borrow.dueDate = Calendar.current.date(byAdding: .day, value: 7 - i, to: Date())!
//        if i % 3 != 0 {
//            borrow.returnDate = nil // Some books are still borrowed
//        }
//    }
//    
//    try? context.save()
//}
//
//struct LibrarianInterface_Previews: PreviewProvider {
//    static var previews: some View {
//        LibrarianInterface()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

// Persistence Controller for Previews
struct PersistenceController {
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        generateSampleData(context: viewContext)
        return result
    }()
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AnyBook")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
