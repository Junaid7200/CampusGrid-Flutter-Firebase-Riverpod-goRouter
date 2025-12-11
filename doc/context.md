# Campus Grid Project

## Routes/Pages general structure

- I assume splash screen doesn't require its own route
- / (get started)
- /login (login page)
- /signup (signup page)
- /home (home tab)
- /search (search tab)
- /library (library tab)
- /profile (profile tab)
- /search/dpt (when the user selects a dpt)
- /search/dpt/degree (the user will select a dpt first and then a degree from that dpt)
- /search/dpt/degree/subject (the user will select a dpt, then a degree in that dpt, and then a subject of that degree)
- /add notes (when user presses the floating action that is visible in home tab and several other tabs then the add notes page would open)
- /view_resource (the page from where the user will be able to download a resource)

## Page -> folder/file

- splash -> lib/src/features/startup/splash.dart
- get_started -> lib/src/features/get_started.dart
- login -> 