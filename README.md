# 🐾 Pet Patrol

## 📌 Overview  
**Pet Patrol** is a Flutter-based mobile application designed to help users manage pet profiles, report lost/found pets, post adoption listings, schedule veterinary appointments, and communicate within the pet community. Built using **Flutter & Firebase**, the app provides a centralized platform for responsible pet care on campus.  

---

## ✨ Implemented Features  

✔️ **User Authentication:** Login, registration, and password recovery via Firebase Authentication.  
✔️ **User Profile Management:** Users can create, update, and manage their personal profiles.  
✔️ **Pet Profile Management:** Users can register pets with details and vaccination records.  
✔️ **Lost & Found Pet Reports:** Users can post about missing or found pets in the community feed.  
✔️ **Pet Adoption Posts:** Users can list pets for adoption and interact with interested adopters.  
✔️ **Real-time Messaging:** Users can send messages to other app users.  
✔️ **Doctor Appointment Booking:** Schedule veterinary appointments for cats and dogs.  

---

## 🛠️ Tech Stack  

- **Frontend:** Flutter (Dart)  
- **Backend:** Firebase Firestore & Firebase Authentication  
- **Cloud Storage:** Firebase Storage (for pet images and user profiles)  
- **Real-time Messaging:** Firebase Firestore  
- **State Management:** Provider (if used)  

---

## 🚀 Installation  

### ✅ Prerequisites  

- Install **Flutter SDK** – [Flutter Install Guide](https://flutter.dev/docs/get-started/install)  
- Set up **Android Studio** or **VS Code** with Flutter plugins  
- Create a **Firebase project** and enable Authentication, Firestore, and Storage  

### 🔧 Setup Steps  

1️⃣ **Clone the Repository:**   <br>
'git clone https://github.com/abirmhasan/PetPatrol.git' <br> 
'cd PetPatrol' <br>

2️⃣ **Install Dependencies:** <br>
'flutter pub get' <br>

3️⃣ **Configure Firebase:** <br>
Add google-services.json (for Android) inside android/app/ <br>
Add GoogleService-Info.plist (for iOS) inside ios/Runner/ <br>
Enable Firebase Authentication, Firestore, and Storage in the Firebase Console <br>
4️⃣ Run the App: <br>
'flutter run'



### 🏆 Challenges and Solutions
🔹 Challenge 1: Firebase Firestore Access Issues <br>
    Issue: Could not retrieve or update data due to Firestore rule misconfigurations. <br>
    Solution: Updated Firestore security rules and ensured authentication for proper access. <br>
    
🔹 Challenge 2: Emulator and Android Studio Setup <br>
    Issue: The app failed to run on an emulator due to missing SDK components. <br>
    Solution: Installed missing dependencies and properly configured the emulator settings. <br>
    
🔹 Challenge 3: Implementing Real-time Messaging <br>
    Issue: Synchronizing real-time messages between users was difficult. <br>
    Solution: Used Firestore's real-time updates and structured message collections properly. <br>
    
🔹 Challenge 4: Doctor Appointment System <br>
    Issue: Managing appointment bookings with available slots was tricky. <br>
  Solution: Implemented Firestore to store and update appointment slots dynamically. <br>

### 🎯 Future Enhancements
✅ Push Notifications: Notify users about new messages, lost pet reports, and adoption posts. <br>
✅ Search & Filter: Allow users to search for pets and adoption posts efficiently. <br>
✅ Offline Support: Enable users to access pet records without an internet connection. <br>
✅ Admin Panel: Implement roles for managing community posts and pet records. <br>

### APK Link
https://drive.google.com/file/d/1QW4JDInVapYvwgWS8afDqyV--OW39Nh0/view?usp=sharing

