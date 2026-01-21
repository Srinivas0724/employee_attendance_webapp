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
    <title>Mark Attendance - Employee Portal</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --card-shadow: 0 10px 30px rgba(0,0,0,0.05);
            --sidebar-width: 280px;
            --danger-red: #e74c3c;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white;
            display: flex;
            flex-direction: column;
            transition: all 0.3s ease;
            flex-shrink: 0;
            z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }

        .sidebar-header {
            padding: 30px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            background: rgba(0,0,0,0.1);
        }

        .sidebar-logo {
            max-width: 130px;
            height: auto;
            margin-bottom: 15px;
            filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2));
        }
        
        .sidebar-brand { 
            font-size: 13px; 
            opacity: 0.9; 
            letter-spacing: 1.5px; 
            text-transform: uppercase; 
            font-weight: 600;
        }

        .nav-menu {
            list-style: none;
            padding: 20px 15px;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item { margin-bottom: 8px; }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            font-weight: 500;
            border-radius: 10px;
            transition: all 0.2s ease;
        }

        .nav-item a:hover {
            background-color: rgba(255,255,255,0.08);
            color: white;
            transform: translateX(5px);
        }

        .nav-item a.active {
            background-color: var(--primary-green);
            color: white;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout {
            width: 100%;
            padding: 14px;
            background-color: rgba(231, 76, 60, 0.9);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
            display: flex; align-items: center; justify-content: center; gap: 10px;
            transition: all 0.2s;
            box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3);
        }
        .btn-logout:hover { background-color: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            position: relative;
        }
        
        .topbar {
            background: white;
            height: 70px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 40px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.03);
            position: sticky; top: 0; z-index: 100;
        }
        
        .page-title { 
            font-size: 22px; 
            font-weight: 700; 
            color: var(--primary-navy); 
            letter-spacing: -0.5px;
        }

        .user-profile { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            background: #f8f9fa;
            padding: 8px 15px;
            border-radius: 30px;
            border: 1px solid #e9ecef;
        }
        
        .user-email { font-size: 13px; color: var(--text-dark); font-weight: 600; }
        .user-avatar { 
            width: 36px; height: 36px; 
            background: var(--primary-navy); 
            color: white;
            border-radius: 50%; 
            display: flex; align-items: center; justify-content: center; 
            font-weight: bold; font-size: 14px;
        }

        /* --- 4. ATTENDANCE CARD --- */
        .content { 
            padding: 40px; 
            display: flex; 
            justify-content: center; 
            align-items: flex-start; 
            min-height: calc(100vh - 70px); 
        }

        .attendance-card { 
            background: white; 
            width: 100%; 
            max-width: 480px; 
            border-radius: 20px; 
            box-shadow: var(--card-shadow); 
            overflow: hidden; 
            border-top: 6px solid var(--primary-green); 
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .card-header { 
            padding: 25px; 
            text-align: center; 
            border-bottom: 1px solid #f1f1f1; 
            background: #fff;
        }
        
        .live-clock { 
            font-size: 42px; 
            font-weight: 800; 
            color: var(--primary-navy); 
            letter-spacing: 1px; 
            margin: 5px 0; 
            font-variant-numeric: tabular-nums;
        }
        
        .live-date { 
            font-size: 14px; 
            color: var(--text-grey); 
            text-transform: uppercase; 
            letter-spacing: 1px; 
            font-weight: 600;
        }
        
        .status-badge { 
            background: #f0fdf4; 
            border: 1px solid #dcfce7; 
            padding: 8px 18px; 
            border-radius: 30px; 
            font-size: 13px; 
            color: var(--text-dark); 
            display: inline-block; 
            margin-top: 15px; 
            font-weight: 700; 
        }

        /* Camera Section */
        .camera-container { 
            position: relative; 
            width: 100%; 
            height: 350px; 
            background: #111; 
            overflow: hidden; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
        }
        
        video { 
            width: 100%; height: 100%; 
            object-fit: cover; 
            /* Flip horizontally ONLY for front camera (handled by JS later ideally, but default flip is okay for selfies) */
            transform: scaleX(-1); 
        }
        
        .overlay-instruction { 
            position: absolute; bottom: 20px; left: 0; width: 100%; 
            text-align: center; color: rgba(255,255,255,0.8); 
            font-size: 13px; text-shadow: 0 2px 4px rgba(0,0,0,0.8); 
            z-index: 10; font-weight: 500;
        }
        
        .btn-start-camera { 
            position: absolute; 
            background: rgba(46, 204, 113, 0.95); 
            color: white; 
            padding: 14px 30px; 
            border-radius: 50px; 
            border: 2px solid white; 
            font-weight: 700; 
            cursor: pointer; 
            z-index: 20; 
            display: flex; align-items: center; gap: 10px; 
            box-shadow: 0 5px 20px rgba(0,0,0,0.4); 
            animation: pulse 2s infinite; 
            font-size: 14px;
        }
        
        @keyframes pulse { 
            0% { transform: scale(1); } 
            50% { transform: scale(1.05); } 
            100% { transform: scale(1); } 
        }
        
        #snapshotPreview { 
            width: 90px; height: 70px; 
            position: absolute; top: 15px; right: 15px; 
            border: 3px solid white; border-radius: 8px; 
            display: none; object-fit: cover; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.3); 
            z-index: 30; 
        }

        /* NEW FLIP BUTTON */
        .btn-flip {
            position: absolute; top: 15px; left: 15px;
            background: rgba(0,0,0,0.6); color: white;
            border: 1px solid rgba(255,255,255,0.3);
            padding: 8px 12px; border-radius: 30px;
            font-size: 12px; cursor: pointer; z-index: 40;
            display: none; /* Hidden until camera starts */
            backdrop-filter: blur(4px);
        }
        .btn-flip:hover { background: rgba(0,0,0,0.8); }

        /* Controls Section */
        .controls-section { padding: 30px; }
        
        .input-group { margin-bottom: 25px; }
        
        .input-group input { 
            width: 100%; padding: 15px 20px; 
            border: 2px solid #e0e0e0; border-radius: 12px; 
            font-size: 14px; transition: 0.3s; outline: none; 
            background: #fcfcfc;
        }
        
        .input-group input:focus { 
            border-color: var(--primary-navy); 
            background: white;
            box-shadow: 0 0 0 4px rgba(26, 59, 110, 0.1);
        }
        
        .btn-row { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 20px; 
        }
        
        .btn-action { 
            padding: 18px; border: none; border-radius: 12px; 
            font-size: 16px; font-weight: 800; color: white; 
            cursor: pointer; transition: all 0.2s; 
            display: flex; align-items: center; justify-content: center; gap: 8px; 
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        
        .btn-action:active { transform: scale(0.96); }
        .btn-action:disabled { opacity: 0.6; cursor: not-allowed; }
        
        .btn-in { 
            background: var(--primary-green); 
            box-shadow: 0 5px 0 #219150; 
            margin-bottom: 5px; 
        }
        .btn-in:active { box-shadow: none; transform: translateY(5px); }
        .btn-in:hover { filter: brightness(1.05); }

        .btn-out { 
            background: var(--danger-red); 
            box-shadow: 0 5px 0 #c0392b; 
            margin-bottom: 5px; 
        }
        .btn-out:active { box-shadow: none; transform: translateY(5px); }
        .btn-out:hover { filter: brightness(1.05); }

        /* Loader */
        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.85); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📍</div>
        <div>Loading Attendance...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="employee_dashboard.jsp"><span class="nav-icon">📊</span> Dashboard</a>
            </li>
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
                <span id="empName" class="user-email">Loading...</span>
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
                    
                    <button id="flipBtn" class="btn-flip" onclick="flipCamera()">🔄 Flip Camera</button>

                    <button id="startBtn" class="btn-start-camera" onclick="startCamera()">
                        <span>📸 Tap to Start Camera</span>
                    </button>

                    <img id="snapshotPreview" alt="Snapshot">
                    <canvas id="canvas" style="display:none"></canvas>
                </div>

                <div class="controls-section">
                    <div class="input-group">
                        <input type="text" id="project" placeholder="Working on a specific project? (Optional)">
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
        let currentFacingMode = 'user'; // Default front camera
        let streamRef = null; // Store stream to stop it later

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    if(role !== 'employee' && role !== 'manager') {
                         // Optional: Handle if someone else logs in
                    }

                    if (doc.data().status === "Disabled") {
                        alert("🚫 Your account is disabled.");
                        auth.signOut().then(() => window.location.replace("index.html"));
                    } else {
                        currentUser = user;
                        document.getElementById("empName").innerText = doc.data().fullName || user.email;
                        document.getElementById("loadingOverlay").style.display = "none";
                        loadLastStatus();
                        
                        // Auto-start camera on Desktop
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

        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }

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
                      statusBadge.style.borderColor = (d.type === 'IN') ? "#2ecc71" : "#e74c3c";
                  } else { 
                      statusBadge.innerText = "No attendance recorded today";
                  }
              });
        }

        // --- 4. CAMERA LOGIC (WITH FLIP) ---
        function startCamera() {
            const vid = document.getElementById("video");
            const btn = document.getElementById("startBtn");
            const flipBtn = document.getElementById("flipBtn");

            // Stop existing stream if any
            if(streamRef) {
                streamRef.getTracks().forEach(track => track.stop());
            }

            navigator.mediaDevices.getUserMedia({ video: { facingMode: currentFacingMode } }).then(stream => {
                streamRef = stream;
                vid.srcObject = stream;
                vid.play();
                btn.style.display = "none";
                flipBtn.style.display = "block"; // Show flip button once camera is on

                // Mirror effect ONLY for front camera
                if(currentFacingMode === 'user') {
                    vid.style.transform = "scaleX(-1)";
                } else {
                    vid.style.transform = "scaleX(1)";
                }

            }).catch(err => {
                console.error(err);
                alert("Camera Access Denied. Please allow permission.");
            });
        }

        function flipCamera() {
            currentFacingMode = (currentFacingMode === 'user') ? 'environment' : 'user';
            startCamera();
        }

        // --- 5. ATTENDANCE LOGIC ---
        function initiateClockIn(type) {
            const vid = document.getElementById("video");
            if (!vid.srcObject) { alert("⚠️ Please start the camera first."); return; }

            const btn = type === 'IN' ? document.getElementById("btnIn") : document.getElementById("btnOut");
            btn.innerHTML = "<span>📍 Locating...</span>";
            btn.disabled = true;

            navigator.geolocation.getCurrentPosition(
                (pos) => processAttendance(type, pos.coords.latitude, pos.coords.longitude, btn),
                (err) => {
                    alert("⚠️ Location Error. Saving with default location.");
                    processAttendance(type, 0, 0, btn);
                },
                { enableHighAccuracy: false, timeout: 15000 }
            );
        }

        function processAttendance(type, lat, lng, btn) {
            const vid = document.getElementById("video");
            const canvas = document.getElementById("canvas");
            let photoData = "NO_CAMERA";
            btn.innerHTML = "<span>💾 Saving...</span>";

            try {
                canvas.width = 480; canvas.height = 360;
                const ctx = canvas.getContext("2d");
                
                // Handle mirroring for canvas drawing too
                if (currentFacingMode === 'user') {
                    ctx.translate(canvas.width, 0);
                    ctx.scale(-1, 1);
                }

                ctx.drawImage(vid, 0, 0, canvas.width, canvas.height);
                
                // Reset transform for text overlay
                ctx.setTransform(1, 0, 0, 1, 0, 0);

                ctx.fillStyle = "rgba(0,0,0,0.5)";
                ctx.fillRect(0, 310, 480, 50);
                ctx.fillStyle = "white";
                ctx.font = "bold 14px Arial";
                ctx.fillText(new Date().toLocaleString(), 15, 330);
                ctx.fillText("Lat: " + lat.toFixed(4) + ", Lng: " + lng.toFixed(4), 15, 350);
                
                photoData = canvas.toDataURL("image/jpeg", 0.7);
                document.getElementById("snapshotPreview").src = photoData;
                document.getElementById("snapshotPreview").style.display = "block";
            } catch(err) { console.error(err); }

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
                btn.disabled = false;
            });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>