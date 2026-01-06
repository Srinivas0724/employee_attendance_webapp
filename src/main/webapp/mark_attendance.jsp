<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-green: #2ecc71;
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-grey: #666;
            --sidebar-width: 260px;
            --danger-red: #e74c3c;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR (Responsive) --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: transform 0.3s ease-in-out;
            flex-shrink: 0;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 20px;
            background-color: rgba(0,0,0,0.1);
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-logo {
            max-width: 140px;
            height: auto;
            margin-bottom: 10px;
            filter: brightness(0) invert(1);
        }
        
        .sidebar-brand { font-size: 14px; opacity: 0.8; letter-spacing: 1px; text-transform: uppercase; }

        .nav-menu {
            list-style: none;
            padding: 20px 0;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .nav-item a:hover, .nav-item a.active {
            background-color: rgba(255,255,255,0.05);
            color: white;
            border-left-color: var(--primary-green);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 20px; border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-logout {
            width: 100%;
            padding: 12px;
            background-color: rgba(231, 76, 60, 0.8);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
        }
        .btn-logout:hover { background-color: #c0392b; }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            position: relative;
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .toggle-btn { display: none; font-size: 24px; cursor: pointer; color: var(--primary-navy); margin-right: 15px; }
        .page-title { font-size: 18px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. ATTENDANCE CARD STYLES --- */
        .content { 
            padding: 20px; 
            display: flex; 
            justify-content: center; 
            align-items: flex-start;
            min-height: calc(100vh - 60px);
        }

        .attendance-card {
            background: white;
            width: 100%;
            max-width: 450px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            overflow: hidden;
            border-top: 5px solid var(--primary-green);
        }

        .card-header { padding: 20px; text-align: center; border-bottom: 1px solid #f1f1f1; }
        .live-clock { font-size: 32px; font-weight: bold; color: var(--primary-navy); letter-spacing: 1px; margin: 5px 0; }
        .live-date { font-size: 13px; color: #888; text-transform: uppercase; letter-spacing: 1px; }

        .status-badge {
            background: #f8f9fa; border: 1px solid #eee; 
            padding: 8px 15px; border-radius: 20px; 
            font-size: 12px; color: #555; display: inline-block; margin-top: 10px;
            font-weight: 600;
        }

        /* Camera Section */
        .camera-container {
            position: relative;
            width: 100%;
            height: 320px;
            background: #000;
            overflow: hidden;
            display: flex; justify-content: center; align-items: center;
        }
        
        video { width: 100%; height: 100%; object-fit: cover; transform: scaleX(-1); }

        .overlay-instruction {
            position: absolute; bottom: 15px; left: 0; width: 100%;
            text-align: center; color: rgba(255,255,255,0.7);
            font-size: 12px; text-shadow: 0 1px 2px rgba(0,0,0,0.8);
            z-index: 10;
        }

        .btn-start-camera {
            position: absolute;
            background: rgba(46, 204, 113, 0.9);
            color: white;
            padding: 12px 25px;
            border-radius: 30px;
            border: 2px solid white;
            font-weight: bold;
            cursor: pointer;
            z-index: 20;
            display: flex; align-items: center; gap: 8px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Snapshot Preview */
        #snapshotPreview {
            width: 80px; height: 60px;
            position: absolute; top: 10px; right: 10px;
            border: 2px solid white; border-radius: 4px;
            display: none; object-fit: cover; box-shadow: 0 2px 5px rgba(0,0,0,0.5);
            z-index: 30;
        }

        /* Controls Section */
        .controls-section { padding: 25px; }

        .input-group { margin-bottom: 20px; }
        .input-group input {
            width: 100%; padding: 12px 15px;
            border: 2px solid #eee; border-radius: 8px;
            font-size: 14px; transition: 0.3s; outline: none;
        }
        .input-group input:focus { border-color: var(--primary-navy); }

        .btn-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

        .btn-action {
            padding: 15px; border: none; border-radius: 8px;
            font-size: 16px; font-weight: bold; color: white;
            cursor: pointer; transition: transform 0.1s, opacity 0.2s;
            display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-action:active { transform: scale(0.98); }
        .btn-action:disabled { opacity: 0.6; cursor: not-allowed; }

        .btn-in { background: var(--primary-green); box-shadow: 0 4px 0 #27ae60; margin-bottom: 4px; }
        .btn-in:active { box-shadow: none; transform: translateY(4px); }

        .btn-out { background: var(--danger-red); box-shadow: 0 4px 0 #c0392b; margin-bottom: 4px; }
        .btn-out:active { box-shadow: none; transform: translateY(4px); }

        /* Loader Overlay */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Mobile Responsive Logic */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
            .main-content { width: 100%; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">📍</div>
        <div>Loading...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="mark_attendance.jsp" class="active"><span class="nav-icon">📍</span> Mark Attendance</a>
            </li>
            <li class="nav-item">
                <a href="employee_tasks.jsp"><span class="nav-icon">📝</span> Assigned Tasks</a>
            </li>
            <li class="nav-item">
                <a href="attendance_history.jsp"><span class="nav-icon">🕒</span> History</a>
            </li>
            <li class="nav-item">
                <a href="employee_expenses.jsp"><span class="nav-icon">💸</span> My Expenses</a>
            </li>
            <li class="nav-item">
                <a href="salary.jsp"><span class="nav-icon">💰</span> My Salary</a>
            </li>
            <li class="nav-item">
                <a href="settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Daily Attendance</div>
            </div>
            <div class="user-profile">
                <span id="empName">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="attendance-card">
                <div class="card-header">
                    <div id="liveDate" class="live-date">...</div>
                    <div id="liveClock" class="live-clock">--:--:--</div>
                    <span id="statusBadge" class="status-badge">Checking status...</span>
                </div>

                <div class="camera-container">
                    <video id="video" autoplay playsinline muted></video>
                    <div class="overlay-instruction">Position your face within the frame</div>
                    
                    <button id="startBtn" class="btn-start-camera" onclick="startCamera()">
                        <span>📸 Tap to Start Camera</span>
                    </button>

                    <img id="snapshotPreview" alt="Snapshot">
                    <canvas id="canvas" style="display:none"></canvas>
                </div>

                <div class="controls-section">
                    <div class="input-group">
                        <input type="text" id="project" placeholder="Working on Project? (Optional)">
                    </div>

                    <div class="btn-row">
                        <button class="btn-action btn-in" id="btnIn" onclick="initiateClockIn('IN')">
                            <span>Clock IN</span>
                        </button>
                        <button class="btn-action btn-out" id="btnOut" onclick="initiateClockIn('OUT')">
                            <span>Clock OUT</span>
                        </button>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <script>
        // --- 1. CONFIG ---
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

        // --- 2. AUTH & LOAD ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    if (!doc.exists || doc.data().status === "Disabled") {
                        alert("🚫 Your account is disabled.");
                        auth.signOut().then(() => window.location.replace("login.jsp"));
                    } else {
                        currentUser = user;
                        document.getElementById("empName").innerText = doc.data().fullName || user.email;
                        document.getElementById("loadingOverlay").style.display = "none";
                        loadLastStatus();
                        
                        // Auto-start camera on Desktop only (save battery on mobile)
                        if(window.innerWidth > 900) startCamera();
                    }
                });
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. UI UTILITIES ---
        function updateTime() {
            const now = new Date();
            document.getElementById("liveClock").innerText = now.toLocaleTimeString([], { hour12: true });
            document.getElementById("liveDate").innerText = now.toLocaleDateString([], { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
        }
        setInterval(updateTime, 1000);
        updateTime();

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        function loadLastStatus() {
            const statusBadge = document.getElementById("statusBadge");
            db.collection("attendance_2025")
              .where("email", "==", currentUser.email)
              .orderBy("timestamp", "desc")
              .limit(1)
              .get()
              .then(snap => {
                  if(!snap.empty) {
                      let d = snap.docs[0].data();
                      let t = new Date(d.timestamp.seconds*1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                      statusBadge.innerText = "Last Action: " + d.type + " at " + t;
                      statusBadge.style.color = (d.type === 'IN') ? "#2ecc71" : "#e74c3c";
                  } else { 
                      statusBadge.innerText = "No attendance recorded today";
                  }
              }).catch(e => {
                  console.log(e);
                  statusBadge.innerText = "Ready to mark";
              });
        }

        // --- 4. CAMERA LOGIC ---
        function startCamera() {
            const vid = document.getElementById("video");
            const btn = document.getElementById("startBtn");

            navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } }).then(stream => {
                vid.srcObject = stream;
                vid.play();
                btn.style.display = "none"; 
            }).catch(err => {
                console.error(err);
                alert("Camera Access Denied. Please enable camera permissions in your browser settings.");
            });
        }

        // --- 5. ATTENDANCE LOGIC ---
        function initiateClockIn(type) {
            const vid = document.getElementById("video");
            
            if (!vid.srcObject) {
                alert("⚠️ Please start the camera first.");
                return; 
            }

            const btn = type === 'IN' ? document.getElementById("btnIn") : document.getElementById("btnOut");
            const originalText = btn.innerHTML;
            
            // Set Loading State
            btn.innerHTML = "<span>📍 Locating...</span>";
            btn.disabled = true;

            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    processAttendance(type, pos.coords.latitude, pos.coords.longitude, btn, originalText);
                },
                (err) => {
                    alert("⚠️ Location Error: " + err.message + ". Saving with default location.");
                    processAttendance(type, 0, 0, btn, originalText);
                },
                { enableHighAccuracy: false, timeout: 15000 }
            );
        }

        function processAttendance(type, lat, lng, btn, originalText) {
            const vid = document.getElementById("video");
            const canvas = document.getElementById("canvas");
            let photoData = "NO_CAMERA";

            // Update button text
            btn.innerHTML = "<span>💾 Saving...</span>";

            try {
                canvas.width = 480; canvas.height = 360;
                const ctx = canvas.getContext("2d");
                
                // Draw Video
                ctx.drawImage(vid, 0, 0, canvas.width, canvas.height);
                
                // Add Overlay Stamp
                ctx.fillStyle = "rgba(0,0,0,0.5)";
                ctx.fillRect(0, 310, 480, 50);
                ctx.fillStyle = "white";
                ctx.font = "bold 14px Arial";
                ctx.fillText(new Date().toLocaleString(), 15, 330);
                ctx.fillText("Lat: " + lat.toFixed(4) + ", Lng: " + lng.toFixed(4), 15, 350);
                
                photoData = canvas.toDataURL("image/jpeg", 0.7);
                
                // Update UI Preview
                const preview = document.getElementById("snapshotPreview");
                preview.src = photoData;
                preview.style.display = "block";
                
            } catch(err) {
                console.error("Capture failed:", err);
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
                alert("✅ Success! You are clocked " + type);
                window.location.reload();
            }).catch(e => {
                alert("Error saving: " + e.message);
                btn.innerHTML = originalText;
                btn.disabled = false;
            });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>