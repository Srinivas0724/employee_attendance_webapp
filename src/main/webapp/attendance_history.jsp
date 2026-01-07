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
    <title>Attendance History - Synod Bioscience</title>
    
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
            --border-color: #eee;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
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

        /* --- 4. HISTORY CONTENT --- */
        .content { padding: 20px; max-width: 1200px; margin: 0 auto; width: 100%; }

        .card { background: white; padding: 0; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f1f1f1; overflow: hidden; }
        
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { text-align: left; padding: 18px 20px; background: #f8f9fa; color: #555; font-size: 13px; text-transform: uppercase; font-weight: 700; border-bottom: 2px solid #eee; }
        td { padding: 15px 20px; border-bottom: 1px solid #f1f1f1; font-size: 14px; color: #333; vertical-align: middle; }
        tr:hover { background-color: #fafafa; }
        tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; color: white; display: inline-block; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-in { background-color: var(--primary-green); box-shadow: 0 2px 5px rgba(46, 204, 113, 0.3); }
        .badge-out { background-color: #e74c3c; box-shadow: 0 2px 5px rgba(231, 76, 60, 0.3); }

        /* Buttons & Links */
        .btn-view { background: white; border: 1px solid #ddd; color: #555; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; transition: 0.2s; }
        .btn-view:hover { background: #f1f1f1; border-color: #ccc; }

        .btn-map { color: var(--primary-navy); text-decoration: none; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 5px; }
        .btn-map:hover { text-decoration: underline; color: #2ecc71; }

        /* Modal */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); align-items: center; justify-content: center; backdrop-filter: blur(3px); }
        .modal-content { background-color: white; padding: 10px; border-radius: 10px; max-width: 90%; max-height: 90%; position: relative; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
        .modal img { max-width: 100%; max-height: 80vh; border-radius: 6px; display: block; }
        .close-btn { position: absolute; top: -15px; right: -15px; background: #e74c3c; color: white; border: 2px solid white; border-radius: 50%; width: 32px; height: 32px; cursor: pointer; font-weight: bold; font-size: 16px; box-shadow: 0 2px 5px rgba(0,0,0,0.2); }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">🕒</div>
        <div>Loading History...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
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
                <span id="userEmail">Loading...</span>
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
                            <tr><td colspan="5" style="text-align:center; padding:30px; color:#777;">Loading data...</td></tr>
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
        db.collection("users").doc(user.email).get().then(doc => {
            if (doc.exists) {
                const role = doc.data().role;
                
                // 1. CHECK ACCESS: Allow Admin OR Manager
                if (role !== 'admin' && role !== 'manager') {
                    window.location.href = "index.html"; // Kick out employees
                    return;
                }

                // 2. LOAD USER INFO
                if(document.getElementById("adminEmail")) {
                     document.getElementById("adminEmail").innerText = user.email;
                }
                
                // 3. IF MANAGER -> HIDE RESTRICTED SIDEBAR LINKS
                if (role === 'manager') {
                    // Change Brand Name
                    const brand = document.querySelector('.sidebar-brand');
                    if(brand) brand.innerText = "MANAGER PORTAL";

                    // Hide Expenses Link (Find by href)
                    const expLink = document.querySelector('a[href="admin_expenses.jsp"]');
                    if(expLink && expLink.parentElement) expLink.parentElement.style.display = 'none';

                    // Hide Payroll Link
                    const payLink = document.querySelector('a[href="payroll.jsp"]');
                    if(payLink && payLink.parentElement) payLink.parentElement.style.display = 'none';
                }

                // 4. LOAD PAGE DATA (Call your page's load function)
                // Note: Ensure the specific page's load function exists (e.g., loadEmployees(), loadTasks())
                // You might need to check which page you are on, or just let the existing code run below this block.
                if(typeof loadEmployeeList === "function") loadEmployeeList();
                if(typeof loadTasks === "function") loadTasks();
                if(typeof loadAttendance === "function") loadAttendance();
                
                // Hide Loader
                const loader = document.getElementById("loadingOverlay");
                if(loader) loader.style.display = "none";
            }
        });
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
                      tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:30px; color:#777;'>No attendance records found.</td></tr>";
                      return;
                  }
                  
                  allRecords = []; 
                  let rowsHtml = "";

                  snapshot.forEach((doc) => {
                      const data = doc.data();
                      allRecords.push(data);
                      const index = allRecords.length - 1;

                      // 1. DATE FORMATTING
                      let dateStr = "No Date";
                      if(data.timestamp && data.timestamp.seconds) {
                          const dateObj = new Date(data.timestamp.seconds * 1000);
                          const datePart = dateObj.toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' });
                          const timePart = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                          dateStr = "<b>" + datePart + "</b> <br> <span style='color:#888; font-size:12px'>" + timePart + "</span>";
                      }

                      // 2. LOCATION (Fixed Link)
                      let mapLink = "<span style='color:#ccc; font-style:italic;'>No Loc</span>";
                      if (data.location && data.location.lat && data.location.lng) {
                          const lat = data.location.lat;
                          const lng = data.location.lng;
                          // Standard Google Maps Link
                          mapLink = "<a class='btn-map' href='https://www.google.com/maps?q=" + lat + "," + lng + "' target='_blank'><span>📍 View Map</span></a>";
                      }

                      // 3. PHOTO BUTTON
                      let photoBtn = "<span style='color:#ccc;'>-</span>";
                      if (data.photo && (data.photo.startsWith("http") || data.photo.startsWith("data:image"))) {
                          photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>📷 View Photo</button>";
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
                      alert("⚠️ Missing Database Index.\nCheck the console (F12) for the creation link.");
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
    </script>
</body>
</html>