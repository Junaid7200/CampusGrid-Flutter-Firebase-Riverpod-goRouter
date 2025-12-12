// import 'package:flutter/material.dart';
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
    // search is ganna need query params for searching and filtering
    GoRoute(path: "/search", builder: (context, state) => SearchPage(
      query: state.uri.queryParameters["query"],
      type: state.uri.queryParameters["type"]
    )),
    GoRoute(path: "/library", builder: (context, state) => LibraryPage(
      query: state.uri.queryParameters["query"],
      sort: state.uri.queryParameters["sort"],
    )),
    GoRoute(path: "/profile", builder: (context, state) => const ProfilePage()),
    // ganna need parameterized routes now
    //degrees of a department:
    GoRoute(path: "/search/dpt/:dptId/degree", builder: (context, state) => 
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
      ),
    ),
    // subjects of a degree
    GoRoute(path: "/search/dpt/:dptId/degree/:degId/subject", builder: (context, state) =>
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
        degId: state.pathParameters["degId"]!,
      ),
    ),
    // notes of a subject
    GoRoute(path: "/search/dpt/:dptId/degree/:degId/subject/:subId/notes", builder: (context, state) =>
      ListDegSubNotesPage(
        dptId: state.pathParameters["dptId"]!,
        degId: state.pathParameters["degId"]!,
        subId: state.pathParameters["subId"]!,
      ),
    ),
    // view a resource
    GoRoute(path: "/view_resource/:resourceId", builder: (context, state) => 
      ViewResourcePage(resourceId: state.pathParameters["resourceId"]!)
    ),
    // add a resource
    GoRoute(path: "/new_resource", builder: (context, state) => const NewResourcePage()),
  ]
);



/*
the main diff from a react-router data router setup is just that in that we don't define query params explicitly or route params, we just extract them in the component simply. We would just use the useParams hook for route params and useSearchParams hook for query params if we were in react-router, goRouter just has a bit more boilerplate but its essentially the same idea.
*/ 