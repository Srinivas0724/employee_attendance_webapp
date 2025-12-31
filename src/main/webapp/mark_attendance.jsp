<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mark Attendance (v6.1 Final)</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; flex-direction: column; }
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; }
@media (max-width: 768px) { .sidebar { display:none; } body { height: auto; } }

.main { flex:1; display:flex; flex-direction:column; }
.header { height:60px; background:#fff; display:flex; justify-content:flex-end; padding:0 20px; align-items:center; border-bottom: 1px solid #dee2e6; }
.content { flex:1; display:flex; justify-content:center; align-items:center; padding: 20px; }
.card { background:#fff; padding:20px; border-radius:8px; width:100%; max-width:420px; text-align:center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
.status { background:#e9ecef; padding:12px; margin-bottom:15px; font-weight: 500; color: #495057; }

/* CAMERA WRAPPER */
.video-wrapper { position: relative; width: 100%; height: 280px; background: #000; border-radius: 5px; margin-bottom: 10px; overflow: hidden; display: flex; justify-content: center; align-items: center; }
video { width: 100%; height: 100%; object-fit: cover; transform: scaleX(-1); }

/* SNAPSHOT PREVIEW */
#snapshotPreview { width: 100px; height: 75px; border: 2px solid #28a745; margin: 10px auto; display: none; object-fit: cover; }

/* START BUTTON */
.overlay-btn { position: absolute; background: #007bff; color: white; padding: 15px 30px; border-radius: 50px; font-size:16px; border: 2px solid white; font-weight: bold; cursor: pointer; z-index: 100; box-shadow: 0 4px 10px rgba(0,0,0,0.3); }

/* INPUTS */
input { width:100%; padding:10px; margin:10px 0; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
button { width:100%; padding:12px; border:none; color:#fff; font-size:16px; font-weight: 600; cursor:pointer; border-radius: 4px; margin-top: 5px; }
.in { background:#28a745; }
.out { background:#dc3545; margin-top:10px; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div id="mainApp" style="display:flex; width: 100%; height: 100%;">
  <div class="sidebar">
    <h2>Dashboard</h2>
    <a href="mark_attendance.jsp" class="active">📍 Mark Attendance</a>
    <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
    <a href="attendance_history.jsp">🕒 Attendance History</a>
    <a href="employee_expenses.jsp">💸 My Expenses</a>
    <a href="salary.jsp">💰 My Salary</a>
    <a href="settings.jsp">⚙️ Settings</a>
    <a href="#" onclick="logout()">🚪 Logout</a>
  </div>

  <div class="main">
    <div class="header"><span id="empName">Loading...</span></div>
    <div class="content">
      <div class="card">
        <h2>Mark Attendance</h2>
        <div class="status" id="statusBox">Loading...</div>
        
        <div class="video-wrapper">
            <video id="video" autoplay playsinline muted></video>
            <div id="startBtn" class="overlay-btn" onclick="startCamera()">📸 TAP TO START CAMERA</div>
        </div>
        
        <img id="snapshotPreview" alt="Preview">
        <canvas id="canvas" style="display:none"></canvas>
        
        <input id="project" placeholder="Project Name (Optional)">
        
        <button class="in" id="btnIn" onclick="initiateClockIn('IN')">Clock IN</button>
        <button class="out" id="btnOut" onclick="initiateClockIn('OUT')">Clock OUT</button>
      </div>
    </div>
  </div>
</div>

<script>
const firebaseConfig = {
  apiKey: "AIzaSyBzdM77WwTSkxvF0lsxf2WLNLhjuGyNvQQ",
  authDomain: "attendancewebapp-ef02a.firebaseapp.com",
  projectId: "attendancewebapp-ef02a",
  storageBucket: "attendancewebapp-ef02a.firebasestorage.app",
  messagingSenderId: "734213881030",
  appId: "1:734213881030:web:bfdcee5a2ff293f87e6bc7"
};

if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let currentUser = null;

// --- 1. SINGLE, ROBUST AUTH CHECK ---
auth.onAuthStateChanged(user => {
    if (user) {
        // Check if user is Disabled/Deleted in DB
        db.collection("users").doc(user.email).get().then(doc => {
            if (!doc.exists) {
                alert("🚫 Your account has been disabled/deleted by Admin.");
                auth.signOut().then(() => window.location.replace("login.jsp"));
            } else {
                // User is Valid
                currentUser = user;
                document.getElementById("empName").innerText = doc.data().fullName || user.email;
                loadData();
                
                // Auto-start camera on desktop
                if(window.innerWidth > 768) startCamera();
            }
        });
    } else {
        window.location.replace("login.jsp");
    }
});

function loadData(){
    db.collection("attendance_2025")
      .where("email", "==", currentUser.email)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get()
      .then(snap => {
          if(!snap.empty) {
              let d = snap.docs[0].data();
              let t = new Date(d.timestamp.seconds*1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
              document.getElementById("statusBox").innerText = "Last: " + d.type + " at " + t;
          } else { 
              document.getElementById("statusBox").innerText = "No attendance today."; 
          }
      }).catch(e => {
          console.error("Data Load Error:", e);
          if(e.message.includes("requires an index")) {
               document.getElementById("statusBox").innerHTML = "<a href='#' style='color:red'>⚠️ Index Missing (See Console)</a>";
          }
      });
}

function startCamera(){
    const vid = document.getElementById("video");
    const btn = document.getElementById("startBtn");

    navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } }).then(stream => {
        vid.srcObject = stream;
        vid.play();
        btn.style.display = "none"; 
    }).catch(err => {
        alert("Camera Error: " + err.message + "\nPlease allow camera permissions.");
    });
}

function initiateClockIn(type) {
    const vid = document.getElementById("video");
    
    // Check if camera is active
    if (!vid.srcObject) {
        alert("⚠️ Camera is OFF! Please tap the blue button to start camera.");
        return; 
    }

    const btn = type === 'IN' ? document.getElementById("btnIn") : document.getElementById("btnOut");
    const originalText = btn.innerText;
    btn.innerText = "Locating...";
    btn.disabled = true;

    navigator.geolocation.getCurrentPosition(
        (pos) => {
            processAttendance(type, pos.coords.latitude, pos.coords.longitude);
            btn.innerText = originalText; btn.disabled = false;
        },
        (err) => {
            alert("⚠️ Location Error: " + err.message + ". Saving with 0,0 location.");
            processAttendance(type, 0, 0);
            btn.innerText = originalText; btn.disabled = false;
        },
        { enableHighAccuracy: false, timeout: 20000 }
    );
}

function processAttendance(type, lat, lng) {
    const vid = document.getElementById("video");
    const canvas = document.getElementById("canvas");
    let photoData = "NO_CAMERA";

    try {
        canvas.width = 480; canvas.height = 360;
        const ctx = canvas.getContext("2d");
        
        ctx.drawImage(vid, 0, 0, canvas.width, canvas.height);
        
        // Add Stamp overlay
        ctx.fillStyle = "rgba(0,0,0,0.6)";
        ctx.fillRect(0, 300, 480, 60);
        ctx.fillStyle = "white";
        ctx.font = "bold 14px sans-serif";
        ctx.fillText(new Date().toLocaleString(), 10, 325);
        ctx.fillText("Loc: " + lat.toFixed(4) + ", " + lng.toFixed(4), 10, 345);
        
        // Convert to Base64 (Using this method avoids Storage Bucket billing issues)
        photoData = canvas.toDataURL("image/jpeg", 0.6);
        
        // Show Preview
        const preview = document.getElementById("snapshotPreview");
        preview.src = photoData;
        preview.style.display = "block";
        
    } catch(err) {
        console.error("Capture failed:", err);
        photoData = "CAPTURE_FAILED";
    }

    const project = document.getElementById("project").value;

    db.collection("attendance_2025").add({
        email: currentUser.email,
        type: type,
        project: project || "General",
        photo: photoData, // Saving image inside DB document
        location: { lat: lat, lng: lng },
        timestamp: firebase.firestore.FieldValue.serverTimestamp(),
        dateString: new Date().toDateString()
    }).then(() => {
        alert("✅ " + type + " Marked Successfully!");
        // Delay reload so user sees preview
        setTimeout(() => window.location.reload(), 2000);
    }).catch(e => {
        alert("Error saving: " + e.message);
    });
}

function logout(){ auth.signOut().then(() => window.location.replace("login.jsp")); }
</script>
</body>
</html>