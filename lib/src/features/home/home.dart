import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_grid/src/shared/widgets/home_header.dart';
import 'package:campus_grid/src/shared/widgets/verstile_card.dart';

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
              child: Column(
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
                        Text(
                          "${_user.displayName}",
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
            HomeHeader(heading: "Most Liked Notes", onActionPressed: () {}),
            // list of most liked notes
            Column(
              children: [
                VerstileCard(
                  title: "Introduction to Flutter",
                  subtitle: "Learn the basics of Flutter development.",
                  cardType: "myNote",
                  // icon: Icons.description_outlined,
                  likesCount: 120,
                  resourcesCount: 5,
                ),
                VerstileCard(
                  title: "Advanced Dart Programming",
                  subtitle: "Deep dive into Dart language features.",
                  cardType: "note",
                  // icon: Icons.description_outlined,
                  likesCount: 95,
                  resourcesCount: 3,
                ),
                // subject type card:
                VerstileCard(
                  title: "Data Structures",
                  subtitle: "Comprehensive resources on data structuresadsffffffffffffffffffffffffffffffffffffffffffffff.",
                  cardType: "subject",
                  // icon: Icons.menu_book_outlined,
                  resourcesCount: 20,
                ),
                // degree type card:
                VerstileCard(
                  title: "Bachelor of Computer Science",
                  subtitle: "All resources for BCS students.",
                  cardType: "degree",
                  // icon: Icons.school_outlined,
                  resourcesCount: 50,
                ),
              ],
            ),

            //heading: Recently added notes
            HomeHeader(heading: "Recently Added Notes", onActionPressed: () {}),
            // list of recently added notes
          ],
        ),
      ),
    );
  }
}
