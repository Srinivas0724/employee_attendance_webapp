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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Attendance History - Synod Bioscience</title>
    
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
        
        .sidebar-brand { font-size: 13px; opacity: 0.9; letter-spacing: 1.5px; text-transform: uppercase; font-weight: 600; }

        .nav-menu { list-style: none; padding: 20px 15px; flex: 1; overflow-y: auto; }
        .nav-item { margin-bottom: 8px; }

        .nav-item a {
            display: flex; align-items: center; padding: 14px 20px;
            color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500;
            border-radius: 10px; transition: all 0.2s ease;
        }

        .nav-item a:hover { background-color: rgba(255,255,255,0.08); color: white; transform: translateX(5px); }
        .nav-item a.active { background-color: var(--primary-green); color: white; box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4); }
        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout {
            width: 100%; padding: 14px; background-color: rgba(231, 76, 60, 0.9);
            color: white; border: none; border-radius: 10px; cursor: pointer;
            font-weight: bold; font-size: 14px; display: flex; align-items: center; justify-content: center; gap: 10px;
            transition: all 0.2s; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3);
        }
        .btn-logout:hover { background-color: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; position: relative; }
        
        .topbar {
            background: white; height: 70px; display: flex; justify-content: space-between; align-items: center;
            padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); position: sticky; top: 0; z-index: 100;
        }
        
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-email { font-size: 13px; color: var(--text-dark); font-weight: 600; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        /* --- 4. HISTORY CONTENT --- */
        .content { padding: 40px; max-width: 1200px; margin: 0 auto; width: 100%; }

        .card { 
            background: white; padding: 0; border-radius: 16px; 
            box-shadow: var(--card-shadow); border-top: 4px solid var(--primary-navy);
            overflow: hidden; 
        }

        .table-responsive { overflow-x: auto; }
        
        table { width: 100%; border-collapse: separate; border-spacing: 0; min-width: 600px; }
        
        th { 
            text-align: left; padding: 18px 20px; background: #f9fafb; 
            color: var(--text-grey); font-size: 12px; text-transform: uppercase; 
            font-weight: 700; border-bottom: 2px solid #eee; letter-spacing: 0.5px;
        }
        
        td { 
            padding: 15px 20px; border-bottom: 1px solid #f1f1f1; 
            font-size: 14px; color: var(--text-dark); vertical-align: middle; 
        }
        
        tr:hover td { background-color: #fcfcfc; }
        tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; color: white; display: inline-block; text-transform: uppercase; }
        .badge-in { background-color: var(--primary-green); box-shadow: 0 2px 5px rgba(46, 204, 113, 0.3); }
        .badge-out { background-color: #e74c3c; box-shadow: 0 2px 5px rgba(231, 76, 60, 0.3); }

        /* Buttons & Links */
        .btn-view { 
            background: #eef2f6; color: var(--primary-navy); border: none; 
            padding: 8px 16px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; 
            display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; 
        }
        .btn-view:hover { background: #dce4eb; transform: translateY(-1px); }

        .btn-map { 
            color: var(--primary-navy); text-decoration: none; font-weight: 600; font-size: 13px; 
            display: inline-flex; align-items: center; gap: 5px; 
            background: rgba(26, 59, 110, 0.05); padding: 5px 10px; border-radius: 5px;
        }
        .btn-map:hover { background: rgba(26, 59, 110, 0.1); }

        /* Modal */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); align-items: center; justify-content: center; backdrop-filter: blur(5px); }
        .modal-content { background-color: white; padding: 15px; border-radius: 16px; max-width: 90%; max-height: 90%; position: relative; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
        .modal img { max-width: 100%; max-height: 80vh; border-radius: 8px; display: block; }
        .close-btn { position: absolute; top: -15px; right: -15px; background: #e74c3c; color: white; border: 3px solid white; border-radius: 50%; width: 36px; height: 36px; cursor: pointer; font-weight: bold; font-size: 18px; box-shadow: 0 5px 15px rgba(0,0,0,0.2); }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.9); backdrop-filter: blur(5px); z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600; }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }

        /* Mobile Optimizations */

@media (max-width: 768px) {

    /* Hide Sidebar by default on mobile */

    .sidebar {

        display: none; 

        position: fixed;

        z-index: 1000;

        width: 250px;

        height: 100%;

    }



    /* Make Content use full width */

    .main-content {

        margin-left: 0 !important;

        width: 100%;

    }



    /* Show a Hamburger Menu Button (You need to add this button to your HTML) */

    .mobile-menu-btn {

        display: block !important; /* Visible only on mobile */

        font-size: 24px;

        background: none;

        border: none;

        color: white; /* or dark color depending on your header */

        cursor: pointer;

    }

    

    /* Adjust Grid/Cards for Mobile */

    .card-container, .stats-row {

        flex-direction: column; /* Stack items vertically */

    }

}

.table-responsive, .attendance-grid-container {

    display: block;

    width: 100%;

    overflow-x: auto; /* Allows horizontal scrolling */

    -webkit-overflow-scrolling: touch; /* Smooth scroll on iPhones */

}
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">🕒</div>
        <div>Loading History...</div>
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
                <a href="mark_attendance.jsp"><span class="nav-icon">📍</span> Mark Attendance</a>
            </li>
            <li class="nav-item">
                <a href="employee_tasks.jsp"><span class="nav-icon">📝</span> Assigned Tasks</a>
            </li>
            <li class="nav-item">
                <a href="attendance_history.jsp" class="active"><span class="nav-icon">🕒</span> History</a>
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
                <div class="page-title">Attendance History</div>
            </div>
            <div class="user-profile">
                <span id="userEmail" class="user-email">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            <div class="card">
                <div class="table-responsive">
                    <table id="historyTable">
                        <thead>
                            <tr>
                                <th>Date & Time</th>
                                <th>Punch Type</th>
                                <th>Project</th>
                                <th>Location</th>
                                <th>Proof</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody">
                            <tr><td colspan="5" style="text-align:center; padding:40px; color:#777;">Loading data...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="photoModal" class="modal" onclick="closeModal()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <button class="close-btn" onclick="closeModal()">×</button>
            <img id="modalImg" src="" alt="Proof">
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

        let allRecords = []; 

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("userEmail").innerText = user.email;
                loadHistory(user.email);
            } else {
                window.location.replace("index.html");
            }
        });

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        // --- 3. LOAD DATA ---
        function loadHistory(email) {
            db.collection("attendance_2025")
              .where("email", "==", email)
              .orderBy("timestamp", "desc")
              .get()
              .then(snapshot => {
                  document.getElementById("loadingOverlay").style.display = "none";
                  const tbody = document.getElementById("tableBody");
                  
                  if (snapshot.empty) {
                      tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:40px; color:#999;'>No attendance records found.</td></tr>";
                      return;
                  }
                  
                  allRecords = []; 
                  let rowsHtml = "";

                  snapshot.forEach((doc) => {
                      const data = doc.data();
                      allRecords.push(data);
                      const index = allRecords.length - 1;

                      // 1. DATE
                      let dateStr = "No Date";
                      if(data.timestamp && data.timestamp.seconds) {
                          const dateObj = new Date(data.timestamp.seconds * 1000);
                          const datePart = dateObj.toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' });
                          const timePart = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                          dateStr = "<div style='font-weight:600; color:var(--primary-navy)'>" + datePart + "</div><div style='color:var(--text-grey); font-size:12px; margin-top:3px;'>" + timePart + "</div>";
                      }

                      // 2. LOCATION (FIXED GOOGLE MAPS LINK)
                      let mapLink = "<span style='color:#ccc; font-size:12px;'>No Loc</span>";
                      if (data.location && data.location.lat && data.location.lng) {
                          const lat = data.location.lat;
                          const lng = data.location.lng;
                          mapLink = `<a class='btn-map' href='https://www.google.com/maps/search/?api=1&query=${lat},${lng}' target='_blank'><span>📍 Map</span></a>`;
                      }

                      // 3. PHOTO BUTTON
                      let photoBtn = "<span style='color:#ccc; font-size:20px;'>-</span>";
                      if (data.photo && (data.photo.startsWith("http") || data.photo.startsWith("data:image"))) {
                          photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>📷 View</button>";
                      }

                      // 4. BADGE
                      let type = data.type || "UNKNOWN";
                      let badgeClass = (type === 'IN') ? 'badge-in' : 'badge-out';

                      rowsHtml += "<tr>";
                      rowsHtml += "<td>" + dateStr + "</td>";
                      rowsHtml += "<td><span class='badge " + badgeClass + "'>" + type + "</span></td>";
                      rowsHtml += "<td>" + (data.project || "General") + "</td>";
                      rowsHtml += "<td>" + mapLink + "</td>";
                      rowsHtml += "<td>" + photoBtn + "</td>";
                      rowsHtml += "</tr>";
                  });
                  
                  tbody.innerHTML = rowsHtml;
              })
              .catch(error => {
                  console.error("Error:", error);
                  if(error.message.includes("requires an index")) {
                      alert("⚠️ System Notification:\nThe database requires a one-time index configuration for history sorting.\nPlease check the browser console for the link.");
                  }
                  document.getElementById("tableBody").innerHTML = "<tr><td colspan='5' style='text-align:center; color:red;'>Error loading data.</td></tr>";
              });
        }

        // --- 4. MODAL LOGIC ---
        function openPhoto(index) {
            const data = allRecords[index];
            const modal = document.getElementById("photoModal");
            const img = document.getElementById("modalImg");
            if(data && data.photo) {
                img.src = data.photo;
                modal.style.display = "flex";
            }
        }

        function closeModal() {
            document.getElementById("photoModal").style.display = "none";
        }

        function logout(){ auth.signOut().then(() => location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>