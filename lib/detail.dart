import 'form.dart';

import 'package:flutter/material.dart';

class Details extends StatelessWidget {
  const Details(this.gig);

  final gig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(gig['name']),
        backgroundColor: Colors.orange,
      ),
      body: MyCustomForm(gig),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm(this.gig, {Key? key}) : super(key: key);
  final gig;

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            widget.gig['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Details: ',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Text(
            widget.gig['description'],
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text('Register'),
              onPressed: () {
                // _isLoading ? null : _register
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => RegisterForm(
                        gigId: widget.gig['id'], gigName: widget.gig['name'])));
              },
            )
          ],
        ),
      ],
    );
  }
}
