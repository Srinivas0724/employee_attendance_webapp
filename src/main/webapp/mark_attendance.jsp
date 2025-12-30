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
<title>Mark Attendance (v6.0 Fix)</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
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

/* Camera Wrapper */
.video-wrapper { position: relative; width: 100%; height: 280px; background: #000; border-radius: 5px; margin-bottom: 10px; overflow: hidden; display: flex; justify-content: center; align-items: center; }
video { width: 100%; height: 100%; object-fit: cover; transform: scaleX(-1); }

/* SNAPSHOT PREVIEW (New) */
#snapshotPreview { width: 100px; height: 75px; border: 2px solid #28a745; margin: 10px auto; display: none; object-fit: cover; }

/* BIG Start Button */
.overlay-btn { position: absolute; background: #007bff; color: white; padding: 15px 30px; border-radius: 50px; font-size:16px; border: 2px solid white; font-weight: bold; cursor: pointer; z-index: 100; box-shadow: 0 4px 10px rgba(0,0,0,0.3); }

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
  <a href="mark_attendance.jsp">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp" class="active">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

    <div class="main">
      <div class="header"><span id="empName">User</span></div>
      <div class="content">
        <div class="card">
          <h2>Mark Attendance (v6.0)</h2>
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
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let currentUser = null;

auth.onAuthStateChanged(user => {
  if (user) {
      currentUser = user;
      loadData();
      if(window.innerWidth > 768) startCamera();
  } else {
      window.location.replace("login.jsp");
  }
});

function loadData(){
  db.collection("users").doc(currentUser.email).get().then(d => { if(d.exists) document.getElementById("empName").innerText = d.data().fullName || currentUser.email; });
  db.collection("attendance_2025").where("email", "==", currentUser.email).orderBy("timestamp", "desc").limit(1).get().then(snap => {
      if(!snap.empty) {
          let d = snap.docs[0].data();
          let t = new Date(d.timestamp.seconds*1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
          document.getElementById("statusBox").innerText = "Last: " + d.type + " at " + t;
      } else { document.getElementById("statusBox").innerText = "No attendance today."; }
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
      alert("Error: " + err.message);
  });
}

function initiateClockIn(type) {
    const vid = document.getElementById("video");
    
    // RELAXED CHECK: Just check if we have a stream, ignore 'readyState' glitches
    if (!vid.srcObject) {
        alert("⚠️ Camera is OFF! Tap the blue button first.");
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

    // FORCE SNAPSHOT
    try {
        canvas.width = 480; canvas.height = 360;
        const ctx = canvas.getContext("2d");
        
        ctx.drawImage(vid, 0, 0, canvas.width, canvas.height);
        
        // Stamp
        ctx.fillStyle = "rgba(0,0,0,0.6)";
        ctx.fillRect(0, 300, 480, 60);
        ctx.fillStyle = "white";
        ctx.font = "bold 14px sans-serif";
        ctx.fillText(new Date().toLocaleString(), 10, 325);
        ctx.fillText("Loc: " + lat.toFixed(4) + ", " + lng.toFixed(4), 10, 345);
        
        photoData = canvas.toDataURL("image/jpeg", 0.6);
        
        // SHOW PREVIEW ON SCREEN (This proves if capture worked)
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
        photo: photoData,
        location: { lat: lat, lng: lng },
        timestamp: firebase.firestore.FieldValue.serverTimestamp(),
        dateString: new Date().toDateString()
    }).then(() => {
        if(photoData.startsWith("data:image")) {
            alert("✅ SUCCESS: Photo Saved! (You should see it below)");
        } else {
            alert("⚠️ Saved with NO PHOTO. Reason: " + photoData);
        }
        // Don't reload immediately so you can see the preview
        setTimeout(() => window.location.reload(), 3000);
    });
}

function logout(){ auth.signOut().then(() => window.location.replace("login.jsp")); }
</script>
</body>
</html>