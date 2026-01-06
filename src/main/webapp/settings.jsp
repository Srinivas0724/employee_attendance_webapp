<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // 1. PASTE THE CACHE CODE HERE (Lines 2-6)
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Settings - emPower</title>

<style>
body { font-family: "Segoe UI", Arial, sans-serif; background:#f4f6f9; margin:0; display:flex; min-height: 100vh; }

/* SIDEBAR (Matched to your other files) */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; }
.header { background:white; padding:15px 25px; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #ddd; height: 60px; }
.content { padding:30px; display:flex; flex-direction:column; align-items:center; gap: 20px; }

.card { background:white; padding:25px; border-radius:8px; width:100%; max-width: 500px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.card h3 { margin-top: 0; color: #333; border-bottom: 2px solid #f4f6f9; padding-bottom: 10px; margin-bottom: 20px; }

.profile-container { display: flex; flex-direction: column; align-items: center; }
.profile-img { width:120px; height:120px; border-radius:50%; border:3px solid #dee2e6; object-fit:cover; margin-bottom: 15px; }

label { font-weight: bold; font-size: 14px; color: #555; display: block; margin-bottom: 5px; }
input { width: 100%; padding: 10px; margin-bottom: 15px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }

button { padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: 500; transition: background 0.2s; }
.btn-primary { background: #007bff; color: white; width: 100%; }
.btn-primary:hover { background: #0056b3; }
.btn-success { background: #28a745; color: white; width: 100%; }
.btn-success:hover { background: #218838; }
.btn-danger { background: #dc3545; color: white; }
.btn-danger:hover { background: #c82333; }

.file-input-wrapper { margin-bottom: 15px; text-align: center; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="sidebar">
  <h2>emPower</h2>
  <a href="mark_attendance.jsp">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp">💰 My Salary</a>
  <a href="settings.jsp" class="active">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<div class="main">
  <div class="header">
    <b>⚙️ Account Settings</b>
    <span id="emailDisplay">Loading...</span>
  </div>

  <div class="content">

    <div class="card">
      <h3>Profile Picture</h3>
      <div class="profile-container">
        <img id="img" class="profile-img" src="https://via.placeholder.com/120?text=User">
        
        <div class="file-input-wrapper">
            <input type="file" id="file" accept="image/*">
        </div>
        <button class="btn-primary" onclick="uploadPic()">Upload New Picture</button>
      </div>
    </div>

    <div class="card">
      <h3>Change Password</h3>
      <label>New Password</label>
      <input type="password" id="newPass" placeholder="Enter new password">
      <button class="btn-success" onclick="changePassword()">Update Password</button>
    </div>

    <div class="card">
      <h3>Change Email Address</h3>
      <div style="background: #fff3cd; color: #856404; padding: 10px; margin-bottom: 15px; font-size: 13px; border-radius: 4px;">
        ⚠️ Changing your email requires a re-login.
      </div>
      <label>New Email</label>
      <input type="email" id="newEmail" placeholder="Enter new email address">
      <button class="btn-success" onclick="changeEmail()">Update Email</button>
    </div>

  </div>
</div>

<script>
/* 🔥 FIREBASE CONFIG */
const firebaseConfig = {
  apiKey: "AIzaSyBzdM77WwTSkxvF0lsxf2WLNLhjuGyNvQQ",
  authDomain: "attendancewebapp-ef02a.firebaseapp.com",
  projectId: "attendancewebapp-ef02a",
  storageBucket: "attendancewebapp-ef02a.firebasestorage.app",
  messagingSenderId: "734213881030",
  appId: "1:734213881030:web:bfdcee5a2ff293f87e6bc7"
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

const auth = firebase.auth();
const db = firebase.firestore();

/* 🔐 AUTH STATE LISTENER */
auth.onAuthStateChanged(user => {
  if (!user) {
    window.location.href = "login.jsp";
    return;
  }

  // Display Email in Header
  document.getElementById("emailDisplay").innerText = user.email;

  // Load existing profile image
  // IMPORTANT: We use user.email to match mark_attendance.jsp logic
  db.collection("users").doc(user.email).get().then(doc => {
    if (doc.exists) {
        const data = doc.data();
        if (data.profileImage) {
            document.getElementById("img").src = data.profileImage;
        }
    }
  });
});

/* 🖼️ UPLOAD PICTURE */
function uploadPic() {
  const user = auth.currentUser;
  const file = document.getElementById("file").files[0];

  if (!file) {
    alert("Please select an image file first.");
    return;
  }

  const imgObj = new Image();
  const reader = new FileReader();

  reader.onload = e => { imgObj.src = e.target.result; };

  imgObj.onload = () => {
    // Resize image using Canvas to save DB space (Max 1MB allowed in Firestore)
    const canvas = document.createElement("canvas");
    const SIZE = 300; // Resize to 300x300px

    canvas.width = SIZE;
    canvas.height = SIZE;

    const ctx = canvas.getContext("2d");
    // Draw image to cover the square
    ctx.drawImage(imgObj, 0, 0, SIZE, SIZE);

    // Convert to Base64 string
    const compressedBase64 = canvas.toDataURL("image/jpeg", 0.7);

    // Save to Firestore under user's EMAIL
    db.collection("users").doc(user.email).set({
      profileImage: compressedBase64
    }, { merge: true })
    .then(() => {
      document.getElementById("img").src = compressedBase64;
      alert("✅ Profile picture updated successfully!");
    })
    .catch(err => {
      console.error(err);
      alert("Error uploading: " + err.message);
    });
  };

  reader.readAsDataURL(file);
}

/* 🔑 CHANGE PASSWORD */
function changePassword() {
    const newPass = document.getElementById("newPass").value;
    const user = auth.currentUser;

    if (newPass.length < 6) {
        alert("Password must be at least 6 characters long.");
        return;
    }

    user.updatePassword(newPass).then(() => {
        alert("✅ Password updated successfully!");
        document.getElementById("newPass").value = "";
    }).catch(error => {
        if (error.code === 'auth/requires-recent-login') {
            alert("⚠️ For security, please Logout and Login again before changing your password.");
            logout();
        } else {
            alert("Error: " + error.message);
        }
    });
}

/* ✉️ CHANGE EMAIL */
function changeEmail() {
  const user = auth.currentUser;
  const newEmail = document.getElementById("newEmail").value;
  const oldEmail = user.email;

  if (!newEmail) {
    alert("Please enter a new email address.");
    return;
  }

  // 1. Update Auth Email
  user.updateEmail(newEmail)
    .then(() => {
      // 2. We need to move user data from Old Email Doc to New Email Doc
      // because we use email as the Document ID.
      const oldDocRef = db.collection("users").doc(oldEmail);
      const newDocRef = db.collection("users").doc(newEmail);

      return oldDocRef.get().then(snap => {
          if (snap.exists) {
              const data = snap.data();
              // Save to new doc ID
              return newDocRef.set(data).then(() => {
                  // Delete old doc ID
                  return oldDocRef.delete();
              });
          }
      });
    })
    .then(() => {
      alert("✅ Email updated! Please login with your new email.");
      logout();
    })
    .catch(err => {
        if (err.code === 'auth/requires-recent-login') {
            alert("⚠️ For security, please Logout and Login again before changing your email.");
            logout();
        } else {
            alert("Error: " + err.message);
        }
    });
}

/* 🚪 LOGOUT */
function logout() {
  auth.signOut().then(() => {
    window.location.href = "index.html";
  });
}
</script>

</body>
</html>

