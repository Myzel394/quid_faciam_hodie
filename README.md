# This project has been replaced by [Relieve](https://github.com/Myzel394/relieve)


<img src="readme_content/poster.webp" />

# Quid Faciam Hodie

## What did I do today?

Find out what you did all these days and unlock moments you completely forgot!


## Showcase

### Available for Android

<p float="left" align="center">
    <img src="readme_content/store_previews/android/0_timeline.webp" width="16%" />
    <img src="readme_content/store_previews/android/1_calendar.webp" width="16%" />
    <img src="readme_content/store_previews/android/2_details_1.webp" width="16%" />
    <img src="readme_content/store_previews/android/2_details_2.webp" width="16%" />
    <img src="readme_content/store_previews/android/3_welcome.webp" width="16%" />
    <img src="readme_content/store_previews/android/4_login.webp" width="16%" />
</p>

### As well as for iOS!

<p float="left" align="center">
    <img src="readme_content/store_previews/ios/0_timeline.webp" width="19%" />
    <img src="readme_content/store_previews/ios/1_calendar.webp" width="19%" />
    <img src="readme_content/store_previews/ios/2_details_1.webp" width="19%" />
    <img src="readme_content/store_previews/ios/2_details_2.webp" width="19%" />
    <img src="readme_content/store_previews/ios/3_welcome.webp" width="19%" />
</p>


## App checkup

* :heart: Created using Flutter
* :apple: Native behavior on Android & iOS
* :white_check_mark: Tested on multiple real devices
* :u7a7a: Completely localized (available in English & German)
* :flashlight: Usage of Supabase's Auth, Database, Storage & Realtime functionality
* :new_moon_with_face: Supports dark mode
* :fast_forward: Optimized for efficient behavior
* :iphone: Includes self-written native modules
* :earth_africa: Uses OpenStreetMap on Android for more privacy; Uses Apple Maps on iOS devices
* :star: Uses animations for awesome User Experience


## Quick start

### Create an account / log in

Go through the welcome screen and log in with your email and password.
If you don't have an account already, we will automatically create one for you.

### Create a new memory

Press on the shutter button once to create a photo.
Hold it down to create a video.

### View your memories

Tap on the bottom right image / movie to view your timeline.
You can swipe to see all your memories from here.


## Hint for the jury

### Team members

* Myzel394

### Instructions

The app can run directly after building it. All API Keys are stored in code.
To protect them from simple bots, they are converted to base64.
Once the Hackathon is over, all API keys will be removed.

By default, this app will use the Supabase project from me (Myzel394).
I do not share your data and I do not download it.
If you want to host your own Supabase project, you can place your
own API key under `lib/constants/apis.dart`;

You will need to replace `SUPABASE_API_URL` to your URL and `SUPABASE_API_URL` to your API key.

If anything goes wrong, you can simply contact me by my GitHub E-Mail.

### How did I use Supabase?

This app uses Supabase's auth for authentication,
databases for storing memories and their location in the
storage, which is used to store the memories and lastly this app
also uses realtime connections to handle memory uploads /
deletes / changes flawlessly.

## Future plans

* Add share functionality
* Add public / private handling
* Publish app in the Play Store & App Store
* Add CI:CD for automatic builds
