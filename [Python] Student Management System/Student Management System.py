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
                    break
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
    # (same code for the graph logic you already have)
    pass

# Function to ensure the file name has a .csv extension
def ensure_csv_extension(file_name):
    if not file_name.lower().endswith('.csv'):
        file_name += '.csv'
        print(f"File extension '.csv' added automatically. New file name: {file_name}")
    return file_name

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
