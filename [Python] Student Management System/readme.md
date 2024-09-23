# Student Management System
This is a Python-based Student Management System that allows users to manage student records, including adding, updating, deleting, filtering, and sorting student data. The program supports CSV import/export functionality, graphical data visualization, and a console-based menu interface for navigation.

## Features
1. Create a New Student:
    * Add a new student to the system by entering their name, student ID, and scores for Math, Science, and English.
    * The program calculates the total score and average score automatically.
2. Update Student Information:
    * Update an existing student’s data by searching with their student ID.
3. Delete Student Record:
    * Delete a student from the system by entering their student ID.
4. Read and Display Student Data:
    * View the list of all students and their scores in a tabular format.
    * The table includes calculated Total Score and Average Score for each student.
    * Class averages for each subject and total are also displayed at the bottom of the table.
5. Filter and Sort Student Data:
    * Filter student records based on conditions like scores or name (e.g., filter by subject scores or names starting with a specific string).
    * Sort the records based on any column in ascending or descending order.
6. Graphical Data Visualization:
    * Visualize student scores using horizontal bar charts with data labels.
7. CSV Import/Export:
    * Import student data from a CSV file and automatically calculate total and average scores.
    * Export student data to a CSV file (without total and average columns).
  
## Dependencies
Please install the following libraries for the program to function:
* [Matplotlib](https://github.com/matplotlib/matplotlib)
* [Tabulate]([https://github.com/matplotlib/matplotlib](https://github.com/astanin/python-tabulate))
    ```
    pip install matplotlib tabulate
    ```
## Installation
```
git clone https://github.com/your-username/student-management-system.git
cd student-management-system
```
Running the program:
```
python student_management_system.py
```
  
## How to Use
### Menu Navigation
Once you run the program, you will be presented with a main menu:
```
--- Main Menu ---
[1]. **[Create]** a new student
[2]. **[Read]** all students
[3]. **[Update]** a student's data
[4]. **[Delete]** a student
[5]. **[Import]** students from a CSV file
[6]. **[Export]** students to a CSV file
[7]. **[Exit]** the program
```
Choose the command you want by typing the number (or the command) in brackets corresponding to the option you want to use.
1. Create a new student
    * When adding a new student, you will need to enter their name, student ID, and scores for Math, Science, and English. The program will automatically calculate the total score and average score.
    * If a student with the same ID already exists, you can choose to either overwrite their data or go back to the menu.
2. Read Student Data
This option allows you to display all student data in a tabular format. Additionally, you can:
* Filter the data: Use `filter()` to apply filters like `Math > 50` or `name = 'John'`.
* Sort the data: Use `sort(column, order)` to sort data. For example, `sort(Total Score, desc)` sorts by total score in descending order.
* Graph the data: Use `graph()` to display horizontal bar charts for Math, Science, and English scores.
3. Update Student Data
Enter a student ID to update the data for that specific student.

4. Delete a Student
Enter the student ID of the student to delete them from the records.

5. Import Students from a CSV
Import student data from a CSV file that contains the following columns: `Name`, `Student ID`, `Math Score`, `Science Score`, and `English Score`. `Total` and `average scores` are automatically calculated and added to the system.

7. Export Students to a CSV
Export the current student data to a CSV file. `Total Score` and `Average Score` columns are **not** included in the exported file.

### CSV File Format
When importing data, the CSV file must contain the following columns:
* `Name`
* `Student ID`
* `Math Score`
* `Science Score`
* `English Score`
Example of a valid csv:
```
Name,Student ID,Math Score,Science Score,English Score
John Doe,101,85,90,88
Jane Smith,102,75,80,85
```
## Error Handling
* Invalid input: If you provide an invalid input (e.g., a non-numeric score or an incorrect sort/filter command), the program will display an error message and allow you to try again.
* Improper Sort Command: If you enter an improper sort command, the program will show an error message and reset the table to the default view.
