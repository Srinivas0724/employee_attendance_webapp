<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Settings - emPower</title>
    <style>
        /* --- LAYOUT --- */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .brand { padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: space-between; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .content { padding: 30px; overflow-y: auto; }

        /* --- SETTINGS CARDS --- */
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .card h3 { margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 10px; color: #333; }
        
        label { display: block; margin-top: 15px; margin-bottom: 5px; font-weight: bold; color: #555; }
        input[type="text"], input[type="email"], input[type="password"], input[type="file"] { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        
        button { border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 15px; }
        .btn-green { background: #28a745; color: white; }
        .btn-green:hover { background: #218838; }
        
        .profile-preview { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 3px solid #ddd; margin-bottom: 10px; display: block; }
        
        .logout-btn { background: #dc3545; color: white; width: 100%; padding: 15px; margin-top: 20px; text-align: center; cursor: pointer; border: none; font-size: 16px; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-storage-compat.js"></script>
</head>
<body>

    <div class="sidebar">
        <div class="brand">emPower</div>
        <ul class="nav-links">
            <li><a href="mark_attendance.jsp">📍 Mark Attendance</a></li>
            <li><a href="employee_tasks.jsp">📝 Assigned Tasks</a></li>
            <li><a href="attendance_history.jsp">🕒 Attendance History</a></li>
            <li><a href="my_expenses.jsp">💸 My Expenses</a></li>
            <li><a href="salary.jsp">💰 My Salary</a></li>
            <li><a href="#" class="active">⚙️ Settings</a></li>
            <li><a href="#" onclick="logout()">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <strong>Settings</strong>
            <span id="userEmailDisplay">Loading...</span>
        </div>

        <div class="content">
            
            <div class="card">
                <h3>📧 Update Email Address</h3>
                <label>Current Email</label>
                <input type="text" id="currentEmail" disabled style="background-color: #e9ecef;">
                
                <label>New Email Address</label>
                <input type="email" id="newEmail" placeholder="Enter new email">
                
                <button class="btn-green" onclick="updateEmailAddr()">Update Email</button>
            </div>

            <div class="card">
                <h3>🔒 Change Password</h3>
                <label>New Password</label>
                <input type="password" id="newPassword" placeholder="Enter new password">
                
                <button class="btn-green" onclick="updateUserPassword()">Update Password</button>
            </div>

            <div class="card">
                <h3>📸 Update Profile Picture</h3>
                <img id="imgPreview" src="https://via.placeholder.com/100" class="profile-preview" alt="Profile">
                
                <label>Select Image</label>
                <input type="file" id="fileInput" accept="image/*" onchange="previewImage(event)">
                
                <button class="btn-green" id="uploadBtn" onclick="uploadProfilePic()">Upload Picture</button>
                <p id="uploadStatus" style="font-size: 12px; color: #666;"></p>
            </div>

            <button class="logout-btn" onclick="logout()">🚪 Logout</button>

        </div>
    </div>

    <script>
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app", // Ensure this bucket exists in console
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };
        
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();
        const storage = firebase.storage(); // Initialize Storage

        // CHECK LOGIN STATE
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("userEmailDisplay").innerText = user.email;
                document.getElementById("currentEmail").value = user.email;
                
                // Load existing photo if available
                if(user.photoURL) {
                    document.getElementById("imgPreview").src = user.photoURL;
                }
            } else {
                window.location.href = "login.jsp";
            }
        });

        // --- 1. UPDATE EMAIL FUNCTION ---
        function updateEmailAddr() {
            const user = auth.currentUser;
            const newEmail = document.getElementById("newEmail").value;

            if(!newEmail) return alert("Please enter a new email.");

            user.updateEmail(newEmail).then(() => {
                // Also update in Firestore 'users' collection so DB stays synced
                db.collection("users").doc(user.email).delete(); // Optional: remove old doc or keep history
                
                // Create new doc reference? Or just rely on Auth. 
                // Usually better to ask user to re-login.
                alert("Email updated! Please login again with your new email.");
                logout();
            }).catch((error) => {
                console.error(error);
                if(error.code === 'auth/requires-recent-login') {
                    alert("Security Alert: Please Logout and Login again to change your email.");
                } else {
                    alert("Error: " + error.message);
                }
            });
        }

        // --- 2. UPDATE PASSWORD FUNCTION ---
        function updateUserPassword() {
            const user = auth.currentUser;
            const newPass = document.getElementById("newPassword").value;

            if(!newPass || newPass.length < 6) return alert("Password must be at least 6 characters.");

            user.updatePassword(newPass).then(() => {
                alert("Password updated successfully!");
                document.getElementById("newPassword").value = "";
            }).catch((error) => {
                if(error.code === 'auth/requires-recent-login') {
                    alert("Security Alert: Please Logout and Login again to change your password.");
                } else {
                    alert("Error: " + error.message);
                }
            });
        }

        // --- 3. UPLOAD PICTURE FUNCTION (Uses Firebase Storage) ---
        function previewImage(event) {
            const reader = new FileReader();
            reader.onload = function(){
                const output = document.getElementById('imgPreview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        }

        function uploadProfilePic() {
            const user = auth.currentUser;
            const file = document.getElementById("fileInput").files[0];
            const statusTxt = document.getElementById("uploadStatus");

            if (!file) return alert("Please select a file first.");

            statusTxt.innerText = "Uploading... please wait.";
            document.getElementById("uploadBtn").disabled = true;

            // Create storage reference: users/USER_ID/profile.jpg
            const storageRef = storage.ref(`users/${user.uid}/profile_${Date.now()}`);

            const uploadTask = storageRef.put(file);

            uploadTask.on('state_changed', 
                (snapshot) => {
                    // Progress indicator (optional)
                    var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                    statusTxt.innerText = "Upload is " + Math.floor(progress) + "% done";
                }, 
                (error) => {
                    // Handle unsuccessful uploads
                    console.error(error);
                    alert("Upload failed. Ensure Firebase Storage is enabled in Console.");
                    document.getElementById("uploadBtn").disabled = false;
                    statusTxt.innerText = "";
                }, 
                () => {
                    // Handle successful uploads on complete
                    uploadTask.snapshot.ref.getDownloadURL().then((downloadURL) => {
                        console.log('File available at', downloadURL);
                        
                        // 1. Update Auth Profile
                        user.updateProfile({ photoURL: downloadURL });
                        
                        // 2. Update Firestore (Optional but recommended)
                        // Note: If you don't have a 'users' collection set up yet, this might fail unless created
                        db.collection("users").doc(user.uid).set({
                            photoURL: downloadURL,
                            email: user.email
                        }, { merge: true });

                        statusTxt.innerText = "Upload Complete!";
                        alert("Profile Picture Updated!");
                        document.getElementById("uploadBtn").disabled = false;
                    });
                }
            );
        }

        function logout() {
            auth.signOut().then(() => window.location.href = "login.jsp");
        }
    </script>
</body>
</html>