import pyodbc
import json
import datetime
from collections import defaultdict

# Database connection details
DRIVER = EnvironmentVar1
SERVER = EnvironmentVar2
DATABASE = EnvironmentVar3
UID = EnvironmentVar4
PWD = EnvironmentVar5
TABLE_NAME = EnvironmentVar6

# Path to the Newman report file
NEWMAN_REPORT_PATH = 'C:Example/Directory' 
# --- End Configuration ---


def process_student_data(executions):
    """
    Processes the 'executions' data, filters students by end_date, and assigns a 
    unique room_slot_id within each (building_id, room_id) group.
    """
    
    today = datetime.date.today()
    all_valid_students = []
    
    # --- STEP 1: Extract and Filter Valid Student Records ---
    print("Step 1: Extracting and filtering valid student records...")
    for execution in executions:
        response = execution['response']
        response_body = None

        if 'body' in response:
            response_body = response['body']
        elif 'stream' in response and response['stream']:
            byte_data = response['stream']['data']
            response_body = bytes(byte_data).decode('utf-8')

        if response_body:
            try:
                parsed_data = json.loads(response_body)
                student_data_list = parsed_data.get('content', [])

                for student in student_data_list:
                    end_date_str = student.get('end_date')
                    
                    # Ensure all required fields exist for room assignment logic
                    required_fields = ['student_id', 'end_date', 'room_id', 'building_id']
                    if not all(student.get(field) for field in required_fields):
                        # print(f"Warning: Missing data in required fields for student_id: {student.get('student_id', 'N/A')}. Skipping.")
                        continue
                        
                    if end_date_str:
                        try:
                            end_date_dt = datetime.datetime.strptime(end_date_str, '%Y-%m-%d').date()
                            
                            # Filter: Check if the end date is after today
                            if end_date_dt > today:
                                student_record = {
                                    'session_id': student.get('session_id'),
                                    'student_id': student.get('student_id'),
                                    'email': student.get('email'),
                                    'application_status': student.get('application_status'),
                                    'start_date': student.get('start_date'),
                                    'end_date': end_date_str,
                                    'building_id': student.get('building_id'),
                                    'room_id': student.get('room_id'),
                                    'price_type_id': student.get('price_type_id'),
                                    'room_slot_id': None 
                                }
                                all_valid_students.append(student_record)
                                
                        except ValueError:
                            print(f"Warning: Could not parse end_date '{end_date_str}' for student_id: {student.get('student_id')}. Skipping.")
                            
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON from response body: {e}")
            
    # --- STEP 2: Group by (building_id, room_id) and Assign room_slot_id ---
    print("Step 2: Grouping by Building/Room and assigning room_slot_id...")
    room_groups = defaultdict(list)
    for student in all_valid_students:
        composite_key = (student['building_id'], student['room_id'])
        room_groups[composite_key].append(student)

    final_insert_data = []
    for composite_key, students_in_room in room_groups.items():
        # Assign sequential slot number (1, 2, 3...) for THIS unique building/room combination
        for i, student in enumerate(students_in_room, 1):
            student['room_slot_id'] = str(i) # Assign the unique slot number as a string
            final_insert_data.append(student)

    print(f"Total valid student records ready for insert: {len(final_insert_data)}")
    return final_insert_data


try:
    # Establish a connection to the database
    cnxn = pyodbc.connect(f'DRIVER={DRIVER};SERVER={SERVER};DATABASE={DATABASE};UID={UID};PWD={PWD}')
    cursor = cnxn.cursor()
    print("Successfully connected to the database.")

    # --- Table Setup ---
    try:
        cursor.execute(f"DROP TABLE {TABLE_NAME}")
        cnxn.commit()
        print(f"Existing table '{TABLE_NAME}' dropped.")
        
    except pyodbc.ProgrammingError:
        pass
    
    cursor.execute(f"""
        CREATE TABLE {TABLE_NAME} (
            session_id varchar(50), 
            id_num varchar(50), 
            email varchar(50), 
            application_status varchar(50),
            start_date date, 
            end_date date, 
            building_id varchar(50), 
            room_id varchar(50), 
            price_type_id varchar(50),
            room_slot_id varchar(50)
        )
    """)
    cnxn.commit()
    print(f"Table '{TABLE_NAME}' created.")
    # --- End Table Setup ---
    
    # Load the JSON file
    with open(NEWMAN_REPORT_PATH, 'r') as f:
        data = json.load(f)

    executions = data['run']['executions']

    # --- Step 3 & 4: Process Data and Execute Bulk Insert ---
    final_data_to_insert = process_student_data(executions)
    
    if not final_data_to_insert:
        print("No valid student data to insert. Exiting script successfully.")
    else:
        sql_insert = f"""
            INSERT INTO {TABLE_NAME} (
                session_id, id_num, email, application_status,
                start_date, end_date, building_id, room_id, price_type_id, room_slot_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        insert_values = [
            (
                student['session_id'], student['student_id'], student['email'], 
                student['application_status'], student['start_date'], student['end_date'], 
                student['building_id'], student['room_id'], student['price_type_id'], 
                student['room_slot_id']
            )
            for student in final_data_to_insert
        ]

        # Use executemany for efficiency
        cursor.executemany(sql_insert, insert_values)
        cnxn.commit()
        print(f"Successfully inserted {len(final_data_to_insert)} records into '{TABLE_NAME}'.")

except pyodbc.Error as e:
    print(f"Database error occurred: {e}")
except json.JSONDecodeError as e:
    print(f"Error decoding main Newman JSON file: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
finally:
    # Close the database connection
    if 'cnxn' in locals() and cnxn:
        cnxn.close()
        print("Database connection closed.")
