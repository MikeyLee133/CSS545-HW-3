import SwiftUI

// Define a data model for tasks
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: Date?
    var isCompleted: Bool = false
}

// Main content view
struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var selectedDate = Date()


    var sortedTasks: [Task] {
        return tasks.sorted { task1, task2 in
            if let dueDate1 = task1.dueDate, let dueDate2 = task2.dueDate {
                return dueDate1 < dueDate2
            } else if task1.dueDate != nil {
                return true // task1 has a due date but task2 doesn't, so task1 comes first
            } else {
                return false // task1 doesn't have a due date, so task2 comes first (or they both don't have due dates)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(sortedTasks) { task in
                        TaskRow(task: task, toggleTaskCompletion: toggleTaskCompletion, deleteTask: deleteTask)
                    }
                    .onDelete(perform: deleteTask) // Enable swipe-to-delete
                }
                .listStyle(PlainListStyle()) // Use plain list style to remove separators
                
                Divider() // Add a divider between list and input section
                
                HStack(spacing: 20) { // Add spacing between elements
                    TextField("Add a new task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity) // Expand to fill available space
                        .padding(.horizontal) // Add horizontal padding
                    
                    DatePicker("Due Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .frame(width: 180) // Set fixed width for DatePicker
                    
                    Button(action: {
                        addTask()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing) // Add trailing padding
                }
                .padding(.vertical, 10) // Add vertical padding
                .background(Color.white) // Set background color to ensure contrast with tab bar
            }
            .navigationTitle("Task Tracker")
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea()) // Set background color of the view
    }

    func toggleTaskCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets) // Remove task at specified offsets
    }

    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        // Determine if the task is special based on your criteria
        let isSpecial = selectedDate.timeIntervalSinceNow < 86400 // Special if due within 24 hours
        
        // Create a new task with the title and due date
        let newTask = Task(title: newTaskTitle, dueDate: selectedDate)
        
        // Add the task to the tasks array
        tasks.append(newTask)
        
        // Reset input fields
        newTaskTitle = ""
        selectedDate = Date()
        
        // Animate a star popping up for special tasks
        if isSpecial {
            withAnimation {
                // Perform your animation here
                // For example, you can change a boolean flag to trigger a view animation
            }
        }
    }




}

// Custom task row view
struct TaskRow: View {
    let task: Task
    let toggleTaskCompletion: (Task) -> Void
    let deleteTask: (IndexSet) -> Void // Adjust delete task action to take IndexSet parameter

    var body: some View {
        HStack {
            Button(action: {
                toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(task.isCompleted ? .green : .primary)
            }
            .buttonStyle(BorderlessButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .gray : .primary)

                if let dueDate = task.dueDate {
                    Text("Due: \(formattedDateString(from: dueDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer() // Add spacer to push the delete button to the right

            Button(action: {
                // Handle deletion by passing the IndexSet to the deleteTask closure
                deleteTask(IndexSet(integer: 0)) // Provide a sample IndexSet, it can be adjusted as needed
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8) // Add vertical padding
        .padding(.horizontal) // Add horizontal padding
        .background(Color(UIColor.systemGray6)) // Set background color
        .cornerRadius(8) // Apply corner radius
    }

    private func formattedDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
