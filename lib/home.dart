import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail.dart';

class GigsPage extends StatefulWidget {
  const GigsPage({Key? key}) : super(key: key);

  @override
  _GigsPageState createState() => _GigsPageState();
}

class _GigsPageState extends State<GigsPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> gigs = [
    {
      'id': '123',
      'image': 'assets/images/flutter_course.png',
      'name': 'Flutter Bootcamp',
      'description':
          'Learn Flutter & Dart Fundamentals With Step-By-Step Instructions To Build any App. Join many learners from around the world already learning today.'
    },
    {
      'id': '321',
      'image': 'assets/images/python_course.jpg',
      'name': 'Python Course',
      'description':
          'Prepare for the Python exam with this comprehensive Python course. Join many learners from around the world learning subjects like Python. Expert Instructors. Pandas Tutorials. Object-Oriented.'
    },
  ];

  Future<bool> _checkRegisterStatus(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;

    final _registrationData =
        await FirebaseFirestore.instance.collection('registrations').get();
    print(_registrationData.docs.length);
    final _registrationStatus = _registrationData.docs.firstWhereOrNull(
        (e) => e['uid'] == user!.uid && e['courseId'] == courseId);
    print('user = ${user!.uid} && course = ${courseId}');

    if (_registrationStatus == null) {
      print('no data found');
      return false;
    }
    print('data was found');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('chose your course'),
        actions: [
          DropdownButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: [
              DropdownMenuItem(
                child: Row(
                  children: const [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text('Logout'),
                  ],
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: gigs.length,
        itemBuilder: (context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Details(gigs[index]),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
              child: Card(
                child: SizedBox(
                  height: 120,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          // height: 120.0,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: Image(
                            image: AssetImage(
                              gigs[index]['image'],
                            ),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 120.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 10.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: const <Widget>[
                                            Icon(
                                              Icons.star,
                                              size: 12.0,
                                              color: Colors.amber,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.0),
                                              child: Text(
                                                '5',
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       left: 4.0),
                                            //   child: Text(
                                            //     "",
                                            //     style: const TextStyle(
                                            //       color: Colors.grey,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Row(
                                //   children: const [
                                //     Icon(
                                //       Icons.check,
                                //       color: Colors.green,
                                //     ),
                                //     Text('Already Registered',
                                //         style: TextStyle(
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.green,
                                //         )),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      gigs[index]['name'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                FutureBuilder(
                                    future:
                                        _checkRegisterStatus(gigs[index]['id']),
                                    initialData: false,
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.data == true) {
                                        return Row(
                                          children: const [
                                            Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            Text(' Registered',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontSize: 10,
                                                )),
                                          ],
                                        );
                                      } else {
                                        return SizedBox();
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
