import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_grid/src/shared/widgets/home_header.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final User _user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text("${_user.displayName}",
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // heading: Most liked notes
            HomeHeader(
              heading: "Most Liked Notes",
              onActionPressed: () {},
            ),
            // list of most liked notes
            //heading: Recently added notes
            HomeHeader(
              heading: "Recently Added Notes",
              onActionPressed: () {},
            ),
            // list of recently added notes
          ],
        ),
      )
    );
  }
}