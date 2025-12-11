# Campus Grid Project

## Functional Requirements

- Auth, login, signup, logout, change profile data, forget password, delete account, google oauth using firebase
- user should be able to view notes and add new notes for other students
- user should be able to upvote notes
- user should be able to save notes to his library
- user should be able to search in anyway vertical he wants (search degrees in a dpt, or subjects in a degree, or notes in a subject, or just write alphabets and get results according to alphabetical matches)
- user should be able to sort (sort by: popularity based on upvotes as well as time)
- pagination
- infinite scroll
- dynamic refetching (user instantly sees a new note uploaded by another user)
- user should be able to search notes in his library as well


## Routes/Pages general structure

- I assume splash screen doesn't require its own route
- / (get started)
- /login (login page)
- /signup (signup page)
- /home (home tab)
- /search (search tab)
- /library (library tab)
- /profile (profile tab)
- /search/dpt/degree (the user will select a dpt first and then a degree from that dpt)
- /search/dpt/degree/subject (the user will select a dpt, then a degree in that dpt, and then a subject of that degree)
- /add notes (when user presses the floating action that is visible in home tab and several other tabs then the add notes page would open)
- /view_resource (the page from where the user will be able to download a resource)

## Page -> folder/file

- splash -> lib/src/features/startup/splash.dart
- get_started -> lib/src/features/get_started.dart
- login -> lib/src/features/auth/login.dart
- signup -> lib/src/features/auth/signup.dart
- home -> lib/src/features/home/home.dart (two main sections, one horizontal scrollview for most liked cards using lib/src/shared/widgets/verstile_card.dart and below that, a recently added cards section also using lib/src/shared/widgets/verstile_card.dart which will be vertical scroll view instead of horizontal)
- search -> lib/src/features/search/search.dart (this is where we will use lib/src/shared/widgets/search_dpt_card.dart. we will have 2 simple sections, a nice search bar and below that are the lib/src/shared/widgets/search_dpt_card.dart cards simply)
- library -> lib/src/features/library/library.dart (2 sections, one search bar and then vertical scroll view of lib/src/shared/widgets/verstile_card.dart)
- profile -> lib/src/features/profile/profile.dart (this page would show the user's uploads and total upvotes and logout and delete account options along with edit profile option to that leads to lib/src/features/profile/edit_profile.dart)

## Note: 

1. the Search Bar will be from lib/src/shared/widgets/search_bar.dart.
2. the lib/src/shared/widgets/search_dpt_card.dart will only be used in search tab, the user will be able to see all the departments there simply
3. the search chaining is simple, the user selects a department, for that department, he sees the degrees offered by that department, then for those degrees, he will see the subjects taught in that degree, and for that subject, he will see the notes of that subject, upon pressing a note he will end up at lib/src/shared/features/resources/view_resource.dart.
4. so we would end up with 4 types of cards in total, a department card (which is lib/src/shared/widgets/search_dpt_card.dart) only used in search.dart, a degree card, a subject card, and a notes card; all three will be handled using lib/src/shared/widgets/verstile_card.dart somehow through a ton of, well props and conditional rendering based on the props if this was react native but I don't know how flutter works but I imagine its somewhat similar.