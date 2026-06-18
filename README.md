# nu_sched_gen

A Flutter app which generates a Nile University schedule subject to constraints and finds empty study rooms

## How It Works

It fetches all courses data from a backend hosting [this code](https://github.com/OakFoil/nu-courses-scraping)

## To quickly give it a try

1. Clone the repository

2. [Install Flutter](https://docs.flutter.dev/install)

3. Get dependencies

   ```bash
   flutter pub get
   ```

4. Generate Files

   ```bash
   flutter pub run build_runner build -d
   ```

5. Run the app

   ```bash
   flutter run --release
   ```
