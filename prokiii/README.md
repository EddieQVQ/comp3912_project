# Prokiii

## Description
Prokiii is an event management application built using Swift and MongoKitten for MongoDB integration. It allows users to create, join, and manage events. Users can log in with Google, update their profile information, and view event details including participant information.

## Account for Tester
prokiiiID: TESTER
email: test@my.bcit.ca
pwd: like12345

## Features
- User authentication using Google Sign-In or email/pwd
- Create, edit events
- Join and leave events
- Manage profile information including uploading profile images
- View event details and participants' team

## Warning
Riot API keys expire every 24 hours. If the API key expires, visit [Riot Developer Portal] (https://developer.riotgames.com/) to regenerate a new key, then replace the key in `ApiManager.swift`.

## Project Structure
- **CreateEventView**: Allows users to create a new event.
- **JoinEventView**: Allows users to join an event by entering a team name.
- **EventDetailView**: Displays details of an event, including participants and their team information.
- **EditEventView**: Allows event creators to edit event details.
- **MongoDBManager**: Singleton class for managing MongoDB operations.
- **GoogleSignInManager**: Manages Google Sign-In and stores user information in MongoDB.
- **ProfileView**: Displays user profile information and provides options to upload a profile image, change Prokiii ID, and log out.
- **ImagePicker**: Utility for picking images from the user's photo library.
- **ApiManager**: Fetches champion rotation data from the Riot Games API.
- **ChangeProkiiiIDView**: Allows users to change their Prokiii ID.

## Imcomplete Tasks
- Forgot password 
- Delete option for Even Owner
- Team Details
- Better UI

## Risks
- If a user logs in using Google, the profile picture function does not work properly.

