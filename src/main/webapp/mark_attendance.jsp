<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Mark Attendance (2025)</title>
    <style>
        /* CSS Same as before */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: flex-end; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .profile-btn { display: flex; align-items: center; gap: 10px; }
        .avatar { width: 35px; height: 35px; background: #007bff; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; }
        .content { padding: 30px; overflow-y: auto; text-align: center; }
        .card { background: white; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .status-box { background: #e9ecef; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold; color: #495057; border-left: 5px solid #ccc; }
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { display: block; font-size: 13px; color: #666; margin-bottom: 5px; }
        .project-input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
        button.action-btn { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px; font-size: 16px; transition: 0.3s; }
        button.action-btn:hover { opacity: 0.9; }
        button:disabled { background: #ccc; cursor: not-allowed; }
        #videoElement { width: 100%; background: black; border-radius: 5px; margin-bottom: 5px; transform: scaleX(-1); }
    </style>
    
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body onload="initApp()">

    <div class="sidebar">
        <div style="padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center;">emPower</div>
        <ul class="nav-links">
            <li><a href="#" class="active">📍 Mark Attendance</a></li>
            <li><a href="employee_tasks.jsp">📝 Assigned Tasks</a></li>
            <li><a href="attendance_history.jsp">🕒 Attendance History</a></li>
            <li><a href="employee_expenses.jsp">💸 My Expenses</a></li>
            <li><a href="salary.jsp">💰 My Salary</a></li>
            <li><a href="settings.jsp">⚙️ Settings</a></li>
            <li><a href="#" onclick="logout()">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <div class="profile-btn">
                <div style="text-align:right;">
                    <span style="display:block; font-weight:bold; font-size:14px;" id="headName">Loading...</span>
                    <span style="display:block; font-size:11px; color:#888;">Employee</span>
                </div>
                <div class="avatar" id="headAvatar">?</div>
            </div>
        </div>

        <div class="content">
            <div class="card">
                <h2>Mark Attendance (2025)</h2>
                
                <div class="status-box" id="currentStatus">
                    Checking records...
                </div>

                <p id="camStatus" style="font-size:12px; color:#888;">Starting Camera...</p>
                <video id="videoElement" autoplay playsinline></video>
                <canvas id="canvas" style="display:none;"></canvas>

                <div class="input-group">
                    <label>Current Project / Task Name (Optional)</label>
                    <input type="text" id="projectInput" class="project-input" placeholder="e.g. Internship Phase 1">
                </div>
                
                <div style="display:flex; gap:10px; justify-content: center;">
                    <button type="button" class="action-btn" style="background:#28a745" onclick="submitAtt('IN')">Clock IN</button>
                    <button type="button" class="action-btn" style="background:#dc3545" onclick="submitAtt('OUT')">Clock OUT</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // --- CONFIG ---
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };

        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();

        let currentUserEmail = "";
        let currentUserName = "";
        let isCameraAvailable = false; 
        const placeholderImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=";

        function initApp() {
            startSmartCamera();
            auth.onAuthStateChanged(user => {
                if(user) {
                    currentUserEmail = user.email;
                    loadProfile(user.email);
                    checkLastStatus(user.email);
                } else {
                    window.location.href = "login.jsp";
                }
            });
        }

        function startSmartCamera() {
            const video = document.getElementById("videoElement");
            const statusText = document.getElementById("camStatus");
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } })
                .then(stream => {
                    video.srcObject = stream;
                    isCameraAvailable = true;
                    statusText.innerText = "✅ Camera Active";
                    statusText.style.color = "green";
                })
                .catch(err => { handleCameraFailure(); });
            } else { handleCameraFailure(); }
        }

        function handleCameraFailure() {
            isCameraAvailable = false;
            document.getElementById("videoElement").style.display = "none"; 
            document.getElementById("camStatus").innerText = "⚠️ No Camera Detected (Photo skipped)";
            document.getElementById("camStatus").style.color = "#d9534f"; 
        }

        function checkLastStatus(email) {
            // --- POINTING TO attendance_2025 ---
            db.collection("attendance_2025").where("userId", "==", email).orderBy("timestamp", "desc").limit(1).get()
                .then(snap => {
                    const statusBox = document.getElementById("currentStatus");
                    if (!snap.empty) {
                        const doc = snap.docs[0].data();
                        const time = doc.timestamp ? new Date(doc.timestamp.seconds * 1000).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : "";
                        statusBox.innerText = `Last entry: ${doc.type} at ${time}`;
                        statusBox.style.borderLeftColor = doc.type === "IN" ? "#28a745" : "#dc3545";
                    } else {
                        statusBox.innerText = "No attendance recorded today.";
                    }
                });
        }

        function loadProfile(email) {
            db.collection("users").doc(email).get().then(doc => {
                if(doc.exists) {
                    const d = doc.data();
                    currentUserName = d.fullName || "Employee";
                    document.getElementById("headName").innerText = currentUserName;
                    document.getElementById("headAvatar").innerText = currentUserName.charAt(0).toUpperCase();
                }
            });
        }

        function logout() { auth.signOut().then(() => window.location.href = "login.jsp"); }

        function submitAtt(type) {
            const btn = event.target;
            const originalText = btn.innerText;
            btn.innerText = "Processing...";
            btn.disabled = true;

            const projectVal = document.getElementById("projectInput").value;
            let finalPhoto = placeholderImage; 

            if (isCameraAvailable) {
                try {
                    const video = document.getElementById("videoElement");
                    const canvas = document.getElementById("canvas");
                    canvas.width = 320; canvas.height = 240;
                    canvas.getContext("2d").drawImage(video, 0, 0, 320, 240);
                    finalPhoto = canvas.toDataURL("image/jpeg", 0.5);
                } catch (e) { }
            }

            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    (position) => { saveToDb(type, projectVal, finalPhoto, position.coords.latitude, position.coords.longitude, btn, originalText); },
                    (error) => { alert("⚠️ GPS Failed. Saving without location."); saveToDb(type, projectVal, finalPhoto, 0.0, 0.0, btn, originalText); }
                );
            } else {
                saveToDb(type, projectVal, finalPhoto, 0.0, 0.0, btn, originalText);
            }
        }

        function saveToDb(type, project, photo, lat, lng, btn, originalText) {
            // --- POINTING TO attendance_2025 ---
            db.collection("attendance_2025").add({
                userId: currentUserEmail,
                email: currentUserEmail,
                userName: currentUserName,
                type: type,
                project: project || "General",
                timestamp: firebase.firestore.FieldValue.serverTimestamp(),
                location: { lat: lat, lng: lng }, 
                photo: photo
            })
            .then(() => {
                alert("Success! Marked " + type);
                location.reload(); // Reload to update status box
            })
            .catch((error) => {
                alert("Database Error: " + error.message);
                btn.innerText = originalText;
                btn.disabled = false;
            });
        }
    </script>
</body>
</html>