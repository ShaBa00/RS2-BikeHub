# RS2-BikeHub

BikeHub mobile and desktop applications are a mix of administrator and user functionalities. In the desktop application,
administrators can perform all the necessary functions specified for administrators, as well as view and add records. 
The mobile application is more focused on user access, where all functionalities are related to the user, with a small 
part for the administrator to facilitate access and management.

## Note: 
Since both the desktop and mobile applications have an administrator section—with the desktop version offering all 
administrative functions and the mobile version offering fewer—to access the administrator section, we recommend following 
the instructions provided in the Word file. Briefly, you need to log in with administrator credentials, navigate to your profile, 
where only the administrative team will be presented with the option to click on the button that leads to the administrator section of the application.

The app was made using .NET and Flutter.

## Setting up

Before setting up the environments, ensure you have:
- Docker installed and running
- RabbitMQ installed
- Flutter
- An Android Emulator like Android Studio

## Running the Application

**Clone the repository:r**
https://github.com/ShaBa00/RS2-BikeHub
2. **Open the main project folder**
"..RS2-BikeHub\BikeHub\Baza\BikeHubBck"
3. **Add the provided .env file to the folder**
Open CMD (Command Prompt) or another terminal and navigate to the location where the project is located
 (.\RS2-BikeHub\BikeHub\Baza\BikeHubBck)
4. **Type in the command:**

docker-compose up --build
Wait for docker to finish composing

To ensure that all parts within Docker have started, within your CMD, if the message 'Subscriber is running...'
 appears two or more times, it could be a positive sign that you can proceed to test the applications

If you want to check only the API endpoints you can open Swagger

Once you have started the API or Docker, you can proceed with launching the applications, which are located in the file fit-build-2025-01-12.zip.

First, you need to unzip the folder, after which you will find:

bikehub_desktop

bikehub_mobile

If you wish to check the desktop application, simply navigate to the Debug folder within bikehub_desktop and launch bikehub_desktop.exe.

If you wish to check the mobile version, navigate to flutter-apk within bikehub_mobile and launch app-debug.apk.

The access credentials for users, that is, the profiles on the applications are the same for both the mobile and desktop applications:

Admin
Username: Admin
Password: admin

Korisnik
Username: Korisnik
Password: korisnik

KorisnikD2
Username: KorisnikD2
Password: korisnikD2

RabbitMQ is used to create a subscription service that operates as follows: when the price of a product is reduced, and a user has saved that product, 
the subscription service is triggered. This service will notify users who have saved the product that its price has been changed.

Detailed instructions for using the applications, specifically the desktop application, can be found in the BikeHubDesktopObjasnjenje Word file,
 while instructions for the mobile application are located in the BikeHubMobileObjasnjenje Word file.
