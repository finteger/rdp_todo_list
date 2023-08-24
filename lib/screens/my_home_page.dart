import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  //Asynchronous function to tfetch tasks data from Firestore
  Future<void> fetchTasksFromFirestore() async {
    //Get a reference to the 'tasks' collection in Firestore
    CollectionReference tasksCollection = db.collection('tasks');

    // Fetch the documents (tasks) from the collection
    QuerySnapshot querySnapshot = await tasksCollection.get();

    // Create an empty list to store fetched task names
    List<String> fetchedTasks = [];

    // Loop through each document (task) in query snapshot
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      // Get the task name from the document's data
      String taskName = docSnapshot.get('name');

      //Get the completion status of the task
      bool completed = docSnapshot.get('completed');

      // Add the task name to the list of fetched tasks
      fetchedTasks.add(taskName);
    }
  }

  //Asynchronous function to update the completion status of a task in Firestore
  Future<void> updateTaskCompletionStatus(
      String taskName, bool completed) async {
    //Get a reference to the 'tasks' collection in Firestore.
    CollectionReference tasksCollection = db.collection('tasks');

    //Query Firestore documents (tasks) with the given task name
    QuerySnapshot querySnapshot =
        await tasksCollection.where('name', isEqualTo: taskName).get();

    //If a matching document is found
    if (querySnapshot.size > 0) {
      //Get a reference to the first matching document
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      //Update the 'completed' field of the document with the new completion status
      await documentSnapshot.reference.update({'completed': completed});
    }
  }

  @override
  void initState() {
    super.initState();

    //Call the function to fetch tasks from Firestore when the widget is initialized
    fetchTasksFromFirestore();
  }

  void addItemToList() async {
    final String taskName = nameController.text;

    //Add to the Firestore collection
    await db.collection('tasks').add({
      'name': taskName,
      'completed': null,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tasks.insert(0, taskName);
      checkboxes.insert(0, false);
    });

    clearTextField();
  }

  final List<String> tasks = <String>[];
  final List<bool> checkboxes = List.generate(8, (index) => false);

  //table_calendar configuration
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  TextEditingController nameController = TextEditingController();

  //To close keyboard after ENTER
  FocusNode _textFieldFocusNode = FocusNode();

  //Clear the input text field;
  void clearTextField() {
    setState(() {
      nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset('assets/rdplogo.png'),
            ),
            Text('Daily Planner',
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 32,
                ))
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TableCalendar(
                    calendarFormat: _calendarFormat,
                    headerVisible: false,
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2022),
                    lastDay: DateTime(2030),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = _selectedDay;
                        _focusedDay = _focusedDay;
                      });
                    }),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: checkboxes[index]
                          ? Colors.green.withOpacity(0.7)
                          : Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !checkboxes[index]
                              ? Icons.manage_history
                              : Icons.playlist_add_check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 18),
                        Text(
                          '${tasks[index]}',
                          style: checkboxes[index]
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(0.5),
                                )
                              : TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 25, right: 25),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: nameController,
                        focusNode: _textFieldFocusNode,
                        style: TextStyle(fontSize: 18),
                        maxLength: 20,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Add To-Do List Item',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                          hintText: 'Enter your task here',
                          hintStyle:
                              TextStyle(fontSize: 16, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: clearTextField,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _textFieldFocusNode.unfocus();
                  addItemToList();
                },
                child: Text('Add To-Do Item'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
