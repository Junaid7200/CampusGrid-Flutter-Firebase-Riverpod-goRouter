import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import "../features/startup/splash.dart";
import "../features/startup/get_started.dart";
import "../features/auth/login.dart";
import "../features/auth/signup.dart";
import "../features/home/home.dart";
import "../features/search/search.dart";
import "../features/library/library.dart";
import "../features/profile/profile.dart";
import "../features/resources/list_deg_sub_notes.dart";
import "../features/resources/new_resource.dart";
import "../features/resources/view_resource.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => const SplashPage()),
    GoRoute(path: "/get-started", builder: (context, state) => const GetStartedPage()),
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
    GoRoute(path: "/signup", builder: (context, state) => const SignupPage()),
    GoRoute(path: "/home", builder: (context, state) => const HomePage()),
    GoRoute(path: "/search", builder: (context, state) => const SearchPage()),
    GoRoute(path: "/library", builder: (context, state) => const LibraryPage()),
    GoRoute(path: "/profile", builder: (context, state) => const ProfilePage()),
    // degrees of a department:
    GoRoute(path: "search/dpt/:dptId/degrees", builder: (context, state) => 
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
      ),
    ),
    // subjects of a degree
    GoRoute(path: "search/dpt/:dptId/degree/:degId/subjects", builder: (context, state) =>
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
        degId: state.pathParameters["degId"]!,
      ),
    ),
    // notes of a subject
    GoRoute(path: "search/dpt/:dptId/degree/:degId/subject/:subId/notes", builder: (context, state) =>
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
        degId: state.pathParameters["degId"]!,
        subId: state.pathParameters["subId"]!,
      ),
    ),
    // add a note
    GoRoute(path: "/add-note", builder: (context, state) => 
      const ViewResourcePage(resourceId: state.pathParameters["resourceId"])
    )
  ]
);