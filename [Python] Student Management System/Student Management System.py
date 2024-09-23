import csv
import operator
import matplotlib.pyplot as plt
from tabulate import tabulate

# Data structure for student data
students = []

# All-in-one input for integer with back() and menu() handling
def get_int_input(prompt, max_value=None):
    while True:
        user_input = input(prompt)

        if user_input.lower() == 'exit()':
            return 'exit()'
        
        if user_input.lower() == 'back()':
            return 'back()'
        
        if user_input.lower() == 'menu()':
            return 'menu()'
        
        try:
            value = int(user_input)
            if max_value is not None and value > max_value:
                print(f"Input value exceeds {max_value}. It will be set to {max_value}.")
                return max_value
            return value
        except ValueError:
            print("Invalid input. Please enter an integer.")

# Check duplicate student by name and ID
def check_duplicate(name, student_id):
    for student in students:
        if student["Student ID"] == student_id:
            return student
    return None

# 1. Create a new student
def create_student():
    while True:
        name = input("Enter student name (or type 'back()', 'menu()', 'exit()'): ")
        if name.lower() == 'exit()':
            return 'exit()'
        if name.lower() == 'menu()':
            return 'menu()'
        if name.lower() == 'back()':
            return 'back()'
        if name.strip() == "":
            print("Student name cannot be empty. Please try again.")
            continue

        student_id = get_int_input("Enter student ID (or type 'back()', 'menu()', 'exit()'): ")
        if student_id == 'exit()':
            return 'exit()'
        if student_id == 'menu()':
            return 'menu()'
        if student_id == 'back()':
            continue 

        # Check for duplicates
        existing_student = check_duplicate(name, student_id)
        if existing_student:
            print(f"A student with the ID '{student_id}' already exists.")
            while True:
                choice = input("Overwrite the data? (yes/no/back()/menu()): ").lower()
                if choice == 'yes':
                    update_student_data(existing_student)
                    return 'menu()'
                elif choice == 'no':
                    return
                elif choice == 'back()':
                    return
                elif choice == 'menu()':
                    return 'menu()'
                else:
                    print("Invalid input. Please type 'yes', 'no', 'back()', or 'menu()'.")
                    continue

        math_score = get_int_input("Enter Math score (max 100): ", max_value=100)
        if math_score == 'exit()':
            return 'exit()'
        if math_score == 'menu()':
            return 'menu()'
        if math_score == 'back()':
            continue
        
        science_score = get_int_input("Enter Science score (max 100): ", max_value=100)
        if science_score == 'exit()':
            return 'exit()'
        if science_score == 'menu()':
            return 'menu()'
        if science_score == 'back()':
            continue
        
        english_score = get_int_input("Enter English score (max 100): ", max_value=100)
        if english_score == 'exit()':
            return 'exit()'
        if english_score == 'menu()':
            return 'menu()'
        if english_score == 'back()':
            continue

        # Adding new student
        total_score = math_score + science_score + english_score
        average_score = total_score / 3
        student = {
            "Name": name,
            "Student ID": student_id,
            "Math Score": math_score,
            "Science Score": science_score,
            "English Score": english_score,
            "Total Score": total_score,
            "Average Score": average_score
        }
        
        students.append(student)
        print(f"Student {name} has been added successfully!")
        break

# Update student data
def update_student_data(student):
    print(f"Updating data for {student['Name']} (ID: {student['Student ID']})")

    math_score = get_int_input("Enter new Math score (max 100): ", max_value=100)
    if math_score == 'back()':
        return
    
    science_score = get_int_input("Enter new Science score (max 100): ", max_value=100)
    if science_score == 'back()':
        return
    
    english_score = get_int_input("Enter new English score (max 100): ", max_value=100)
    if english_score == 'back()':
        return

    student["Math Score"] = math_score
    student["Science Score"] = science_score
    student["English Score"] = english_score
    student["Total Score"] = math_score + science_score + english_score
    student["Average Score"] = student["Total Score"] / 3

    print(f"Student {student['Name']}'s data has been updated successfully!")

# Display student data
def read_students():
    if not students:
        print("No student data available.")
        return

    headers = ["Name", "Student ID", "Math Score", "Science Score", "English Score", "Total Score", "Average Score"]
    filtered_students = students  # Start with the full list

    while True:
        # Display current table
        display_table(filtered_students, headers)

        user_input = input("\nEnter a filter (e.g., 'filter(Science > 50)') or reset filter by filter(reset), sort (e.g., 'sort(ID, Desc)', or 'menu()'/'back()' to return to main menu: ").strip().lower()

        if user_input == 'menu()' or user_input == 'back()':
            return 'menu()'
        elif user_input == 'exit()':
            return 'exit()'
        elif 'graph()' in user_input:
            display_graph(filtered_students)
        elif user_input == 'filter(reset)':
            # Reset the filtered_students list to the original students list
            filtered_students = students
            print("Filters have been reset. Displaying the full list.")
        else:
            try:
                # Handle filtering and sorting commands
                filtered_students = handle_filter_and_sort(user_input, filtered_students)
                if not filtered_students:
                    print("No records match the filter criteria.")
            except (ValueError, KeyError) as e:
                print(f"Improper command. Error: {str(e)}")


# Helper function to handle both filtering and sorting
def handle_filter_and_sort(command, students_list):
    # Extract filter and sort parts
    filter_part = sort_part = None

    if 'filter(' in command:
        # Reset the filtered_students list to the original students list
        filtered_students = students
        filter_start = command.find('filter(') + len('filter(')
        filter_end = command.find(')', filter_start)
        filter_part = command[filter_start:filter_end]

    if 'sort(' in command:
        sort_start = command.find('sort(') + len('sort(')
        sort_end = command.find(')', sort_start)
        sort_part = command[sort_start:sort_end]

    # Apply filtering
    if filter_part:
        students_list = apply_filter(filter_part.strip(), students_list)

    # Apply sorting
    if sort_part:
        column, order = extract_sort_command(sort_part.strip())
        students_list = sort_students(students_list, column, order)

    return students_list

# Apply filters based on user input
def apply_filter(filter_input, students_list):
    ops = {
        ">": operator.gt,
        "<": operator.lt,
        ">=": operator.ge,
        "<=": operator.le,
        "==": operator.eq
    }

    conditions = filter_input.lower().split("and")
    filtered_students = students_list

    for condition in conditions:
        condition = condition.strip()

        for op_symbol, op_func in ops.items():
            if op_symbol in condition:
                try:
                    column, value = condition.split(op_symbol)
                    column = column.strip().lower()
                    value = value.strip()

                    if column == "name":
                        filtered_students = list(filter(lambda s: value.strip("'").lower() in s["Name"].lower(), filtered_students))
                    elif column == "id":
                        filtered_students = list(filter(lambda s: op_func(s["Student ID"], int(value)), filtered_students))
                    elif column == "math":
                        filtered_students = list(filter(lambda s: op_func(s["Math Score"], float(value)), filtered_students))
                    elif column == "science":
                        filtered_students = list(filter(lambda s: op_func(s["Science Score"], float(value)), filtered_students))
                    elif column == "english":
                        filtered_students = list(filter(lambda s: op_func(s["English Score"], float(value)), filtered_students))
                    elif column == "total":
                        filtered_students = list(filter(lambda s: op_func(s["Total Score"], float(value)), filtered_students))
                    elif column == "average":
                        filtered_students = list(filter(lambda s: op_func(s["Average Score"], float(value)), filtered_students))
                    else:
                        print(f"Unknown column '{column}' in filter condition.")
                        return []
                except ValueError:
                    print(f"Invalid filter condition: {condition}")
                    return []
                break
        else:
            print(f"Invalid operator in condition: {condition}")
            return []

    return filtered_students

# Extract sort command
def extract_sort_command(command):
    column, order = command.split(',')
    return column.strip(), order.strip().lower()

# Sort students
def sort_students(students_list, column, order):
    reverse = True if order == 'desc' else False
    match column.lower():
        case "name":
            column = "Name"
        case "math":
            column = "Math Score"
        case "science":
            column = "Science Score"
        case "english":
            column = "English Score"
        case "id":
            column = "Student ID"
        case "total":
            column = "Total Score"
        case "average":
            column = "Average Score"
        case _:
            print("Invalid variable, defaulted to Student ID")
            column = "Student ID"
    return sorted(students_list, key=lambda s: s[column], reverse=reverse)

# Display the table
def display_table(filtered_students, headers):
    table = [[s["Name"], s["Student ID"], s["Math Score"], s["Science Score"], s["English Score"], s["Total Score"], f"{s['Average Score']:.2f}"] for s in filtered_students]
    print("\nStudent Records:")
    print(tabulate(table, headers, tablefmt="grid"))

# Function to display graphs based on filtered or full data
def display_graph(students_to_graph):
    if not students_to_graph:
        print("No student data to display.")
        return

    # Sort the students by their scores for each subject in descending order
    students_to_graph_sorted_by_math = sorted(students_to_graph, key=lambda s: s["Math Score"], reverse=True)
    students_to_graph_sorted_by_science = sorted(students_to_graph, key=lambda s: s["Science Score"], reverse=True)
    students_to_graph_sorted_by_english = sorted(students_to_graph, key=lambda s: s["English Score"], reverse=True)

    # Font size for labels (reduced by 50%)
    label_font_size = 7

    # Math scores (Horizontal Bar Chart)
    student_names = [s["Name"] for s in students_to_graph_sorted_by_math]
    math_scores = [s["Math Score"] for s in students_to_graph_sorted_by_math]
    class_avg_math = sum(math_scores) / len(students_to_graph)

    plt.figure(figsize=(10, 12))
    plt.barh(student_names, math_scores, label="Math Scores")
    plt.axvline(x=class_avg_math, color='r', linestyle='--', label=f"Class Avg Math: {class_avg_math:.2f}")
    plt.title("Math Scores", fontsize=label_font_size * 1.5)
    plt.ylabel("Students", fontsize=label_font_size)
    plt.xlabel("Scores", fontsize=label_font_size)
    
    # Adding data labels on the right side of the bars
    for i, score in enumerate(math_scores):
        plt.text(score + 1, i, f'{score}', va='center', fontsize=label_font_size)

    plt.xticks(fontsize=label_font_size)
    plt.yticks(fontsize=label_font_size)
    plt.legend(fontsize=label_font_size)
    plt.tight_layout()
    plt.show()

    # Science scores (Horizontal Bar Chart)
    student_names = [s["Name"] for s in students_to_graph_sorted_by_science]
    science_scores = [s["Science Score"] for s in students_to_graph_sorted_by_science]
    class_avg_science = sum(science_scores) / len(students_to_graph)

    plt.figure(figsize=(10, 12))
    plt.barh(student_names, science_scores, label="Science Scores", color='g')
    plt.axvline(x=class_avg_science, color='r', linestyle='--', label=f"Class Avg Science: {class_avg_science:.2f}")
    plt.title("Science Scores", fontsize=label_font_size * 1.5)
    plt.ylabel("Students", fontsize=label_font_size)
    plt.xlabel("Scores", fontsize=label_font_size)
    
    # Adding data labels on the right side of the bars
    for i, score in enumerate(science_scores):
        plt.text(score + 1, i, f'{score}', va='center', fontsize=label_font_size)

    plt.xticks(fontsize=label_font_size)
    plt.yticks(fontsize=label_font_size)
    plt.legend(fontsize=label_font_size)
    plt.tight_layout()
    plt.show()

    # English scores (Horizontal Bar Chart)
    student_names = [s["Name"] for s in students_to_graph_sorted_by_english]
    english_scores = [s["English Score"] for s in students_to_graph_sorted_by_english]
    class_avg_english = sum(english_scores) / len(students_to_graph)

    plt.figure(figsize=(10, 12))
    plt.barh(student_names, english_scores, label="English Scores", color='b')
    plt.axvline(x=class_avg_english, color='r', linestyle='--', label=f"Class Avg English: {class_avg_english:.2f}")
    plt.title("English Scores", fontsize=label_font_size * 1.5)
    plt.ylabel("Students", fontsize=label_font_size)
    plt.xlabel("Scores", fontsize=label_font_size)
    
    # Adding data labels on the right side of the bars
    for i, score in enumerate(english_scores):
        plt.text(score + 1, i, f'{score}', va='center', fontsize=label_font_size)

    plt.xticks(fontsize=label_font_size)
    plt.yticks(fontsize=label_font_size)
    plt.legend(fontsize=label_font_size)
    plt.tight_layout()
    plt.show()

# Function to export student data to a CSV file (without Total Score and Average Score columns)
def export_to_csv():
    file_name = input("Enter the CSV file name to export to (or type 'back()' to go back, 'exit()' to exit): ")
    if file_name.lower() == 'exit()':
        print("Exiting the program. Goodbye!")
        exit()
    if file_name.lower() == 'back()':
        return
    
    file_name = ensure_csv_extension(file_name)
    
    try:
        # Only write the fields without "Total Score" and "Average Score"
        with open(file_name, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=["Name", "Student ID", "Math Score", "Science Score", "English Score"])
            writer.writeheader()
            writer.writerows(students)
            print(f"Successfully exported {len(students)} students to {file_name}.")
    except Exception as e:
        print(f"An error occurred while exporting data: {e}")

# Function to import student data from a CSV file (adding Total and Average scores)
def import_from_csv():
    file_name = input("Enter the CSV file name to import from (or type 'back()' to go back, 'exit()' to exit): ")
    if file_name.lower() == 'exit()':
        print("Exiting the program. Goodbye!")
        exit()
    if file_name.lower() == 'back()':
        return

    file_name = ensure_csv_extension(file_name)
    
    try:
        with open(file_name, mode='r') as file:
            reader = csv.DictReader(file)
            imported_students = []
            for row in reader:
                # Calculate total and average scores
                total_score = int(row["Math Score"]) + int(row["Science Score"]) + int(row["English Score"])
                average_score = total_score / 3

                # Create the student dictionary and include the calculated total and average scores
                student = {
                    "Name": row["Name"],
                    "Student ID": int(row["Student ID"]),
                    "Math Score": min(int(row["Math Score"]), 100),
                    "Science Score": min(int(row["Science Score"]), 100),
                    "English Score": min(int(row["English Score"]), 100),
                    "Total Score": total_score,
                    "Average Score": average_score
                }

                # Check for duplicates during import
                existing_student = check_duplicate(student["Name"], student["Student ID"])
                if existing_student:
                    print(f"Duplicate found for '{student['Name']}' with ID '{student['Student ID']}' in CSV. Skipping import for this record.")
                    continue

                imported_students.append(student)
            students.extend(imported_students)
            print(f"Successfully imported {len(imported_students)} students from {file_name}.")
    except FileNotFoundError:
        print(f"File '{file_name}' not found. Please check the file name and try again.")
    except KeyError:
        print(f"CSV file must contain the following columns: Name, Student ID, Math Score, Science Score, English Score.")
    except ValueError:
        print("Invalid data format in CSV file. Please ensure all scores and Student ID are integers.")



# Function to ensure the file name has a .csv extension
def ensure_csv_extension(file_name):
    if not file_name.lower().endswith('.csv'):
        file_name += '.csv'
        print(f"File extension '.csv' added automatically. New file name: {file_name}")
    return file_name

def delete_student():
    while True:
        student_id = get_int_input("Enter the Student ID of the student to delete (or type 'back()' to go back, 'exit()' to exit): ")
        if student_id == 'exit()':
            print("Exiting the program. Goodbye!")
            exit()
        if student_id == 'back()':
            return

        # Search for the student by Student ID
        for student in students:
            if student["Student ID"] == student_id:
                students.remove(student)
                print(f"Student with ID {student_id} has been deleted successfully!")
                return

        print(f"No student found with the ID {student_id}.")

def main_menu():
    while True:
        print("\n--- Main Menu ---")
        print("[1]. Create a new student")
        print("[2]. Read all students")
        print("[3]. Update a student's data")
        print("[4]. Delete a student")
        print("[5]. Import students from a CSV file")
        print("[6]. Export students to a CSV file")
        print("[7]. Exit the program")

        choice = input("Enter your choice as shown in square brackets: ").strip().lower()

        match choice:
            case "1" | "create":
                result = create_student()
                if result == 'exit()':
                    break
            case "2" | "read":
                read_students()
            case "3" | "update":
                result = update_student()
                if result == 'exit()':
                    break
            case "4" | "delete":
                result = delete_student()
                if result == 'exit()':
                    break
            case "5" | "import":
                result = import_from_csv()
                if result == 'exit()':
                    break
            case "6" | "export":
                result = export_to_csv()
                if result == 'exit()':
                    break
            case "7" | "exit()" | "exit":
                print("Thank you for using our application!")
                break
            case _:
                print("Invalid input. Please try again.")

# Start the program
main_menu()
