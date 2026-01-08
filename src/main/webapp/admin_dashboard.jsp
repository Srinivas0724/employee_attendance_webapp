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
    <title>Live Dashboard - Synod Bioscience</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
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
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: width 0.3s;
            flex-shrink: 0;
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
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .page-title { font-size: 20px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* DASHBOARD CONTENT */
        .dashboard-container { padding: 30px; max-width: 1400px; margin: 0 auto; width: 100%; }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-left: 5px solid transparent;
        }
        
        .stat-info h3 { margin: 0; font-size: 14px; color: #7f8c8d; text-transform: uppercase; }
        .stat-info .number { font-size: 28px; font-weight: bold; color: #2c3e50; margin-top: 5px; }
        .stat-icon { font-size: 32px; opacity: 0.3; }

        .border-blue { border-left-color: #3498db; }
        .border-green { border-left-color: #2ecc71; }
        .border-orange { border-left-color: #f39c12; }

        /* Table Section */
        .table-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            padding: 25px;
            overflow: hidden;
        }

        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .table-header h3 { color: var(--text-dark); margin:0; }
        
        /* Live Badge Animation */
        .live-badge { 
            background: #e74c3c; color: white; padding: 5px 12px; 
            border-radius: 20px; font-size: 12px; font-weight: bold; 
            box-shadow: 0 0 10px rgba(231, 76, 60, 0.4);
            animation: pulse 1.5s infinite; 
        }

        @keyframes pulse { 
            0% { opacity: 1; transform: scale(1); } 
            50% { opacity: 0.8; transform: scale(1.05); } 
            100% { opacity: 1; transform: scale(1); } 
        }

        /* Table Styles */
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8f9fa; text-align: left; padding: 15px; color: #666; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #f1f1f1; color: #444; font-size: 14px; vertical-align: middle; }
        tr:hover { background-color: #fafafa; }

        .status-badge { padding: 5px 12px; border-radius: 15px; font-size: 12px; font-weight: bold; display: inline-block; }
        .badge-in { background: #d4edda; color: #155724; }
        .badge-out { background: #f8d7da; color: #721c24; }

        .btn-view {
            background: #3498db; color: white; border: none;
            padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 12px;
        }
        .btn-view:hover { background: #2980b9; }

        /* Modal */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); align-items: center; justify-content: center; }
        .modal-content { background-color: #fff; padding: 10px; border-radius: 8px; max-width: 500px; width: 90%; text-align: center; position: relative; }
        .modal img { max-width: 100%; border-radius: 4px; }
        .close-btn { position: absolute; top: -15px; right: -15px; background: red; color: white; border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; font-weight: bold; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column; color: #333; }
        
        /* Responsive */
        @media (max-width: 900px) {
            .sidebar { position: absolute; left: -260px; height: 100%; z-index: 200; }
            .sidebar.open { left: 0; }
            .toggle-btn { display: block; margin-right: 15px; cursor: pointer; font-size: 24px; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">📊</div>
        <div>Loading Dashboard Data...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a>
            </li>
            <li class="nav-item">
                <a href="admin_dashboard.jsp" class="active"><span class="nav-icon">📊</span> Live Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a>
            </li>
            <li class="nav-item">
                <a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a>
            </li>
            <li class="nav-item">
                <a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a>
            </li>
             <li class="nav-item">
                <a href="payroll.jsp"><span class="nav-icon">💰</span> Payroll</a>
            </li>
            <li class="nav-item">
                <a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">Live Overview</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="dashboard-container">
            
            <div class="stats-grid">
                <div class="stat-card border-blue">
                    <div class="stat-info">
                        <h3>Total Employees</h3>
                        <div class="number" id="totalEmp">0</div>
                    </div>
                    <div class="stat-icon">👥</div>
                </div>

                <div class="stat-card border-green">
                    <div class="stat-info">
                        <h3>Today's Activity</h3>
                        <div class="number" id="presentToday">0</div>
                    </div>
                    <div class="stat-icon">⚡</div>
                </div>

                <div class="stat-card border-orange">
                    <div class="stat-info">
                        <h3>Pending Actions</h3>
                        <div class="number" id="pendingCount">0</div>
                    </div>
                    <div class="stat-icon">⏳</div>
                </div>
            </div>

            <div class="table-card">
                <div class="table-header">
                    <h3>Real-Time Attendance Feed</h3>
                    <span class="live-badge">● LIVE</span>
                </div>
                
                <table>
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>Employee</th>
                            <th>Status</th>
                            <th>Project</th>
                            <th>Location</th>
                            <th>Photo</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <tr><td colspan="6" style="text-align:center;">Waiting for updates...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>
    </div>

    <div id="photoModal" class="modal" onclick="closeModal()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <button class="close-btn" onclick="closeModal()">×</button>
            <h4 style="margin-bottom:10px; color:#333;">Selfie Verification</h4>
            <img id="modalImg" src="">
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
                    if (doc.exists && doc.data().role === 'admin') {
                        document.getElementById("adminEmail").innerText = user.email;
                        document.getElementById("loadingOverlay").style.display = "none";
                        loadDashboardData();
                    } else {
                        alert("Access Denied: Admins Only");
                        logout();
                    }
                }).catch(e => {
                    console.error(e);
                    // Fallback for bootstrap
                    document.getElementById("loadingOverlay").style.display = "none";
                    loadDashboardData();
                });
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. DATA LOADING ---
        function loadDashboardData() {
            // A. Employee Count
            db.collection("users").where("role", "!=", "admin").get().then(snap => {
                document.getElementById("totalEmp").innerText = snap.size;
            });

            // B. Pending Approvals
            db.collection("users").where("status", "==", "Pending").get().then(snap => {
                document.getElementById("pendingCount").innerText = snap.size;
            });

            // C. Live Feed (Real-time Listener)
            db.collection("attendance_2025")
              .orderBy("timestamp", "desc")
              .limit(15) 
              .onSnapshot(snapshot => {
                  let actionCount = 0;
                  let html = "";
                  allRecords = []; 

                  if(snapshot.empty) {
                      document.getElementById("tableBody").innerHTML = "<tr><td colspan='6' style='text-align:center; padding:20px;'>No attendance records found today.</td></tr>";
                      return;
                  }

                  snapshot.forEach(doc => {
                      const data = doc.data();
                      actionCount++;
                      allRecords.push(data);
                      const index = allRecords.length - 1;
                      
                      // 1. TIME
                      let time = "N/A";
                      if (data.timestamp) {
                          time = new Date(data.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                      }
                      
                      // 2. SAFE VARIABLES (Default to String to avoid "False")
                      const empEmail = data.email || "Unknown User";
                      const project = data.project || "General";
                      
                      // 3. BADGE
                      const type = data.type || "UNKNOWN";
                      const badgeClass = (type === "IN") ? "badge-in" : "badge-out";

                      // 4. MAP
                      let mapLink = "<span style='color:#ccc'>No GPS</span>";
                      if(data.location && data.location.lat) {
                          mapLink = "<a href='https://www.google.com/maps/search/?api=1&query=" + data.location.lat + "," + data.location.lng + "' target='_blank' style='color:#3498db; text-decoration:none; font-weight:bold;'>📍 Map</a>";
                      }

                      // 5. PHOTO
                      let photoBtn = "<span style='color:#ccc; font-size:12px'>No Pic</span>";
                      if (data.photo) {
                           photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>📷 View</button>";
                      }

                      // ⚠️ IMPORTANT: We use string concatenation (+) instead of backticks (`...`)
                      // This prevents JSP from trying to interpret ${variables} as server-side code.
                      html += "<tr>";
                      html += "<td><b>" + time + "</b></td>";
                      html += "<td>" + empEmail + "</td>";
                      html += "<td><span class='status-badge " + badgeClass + "'>" + type + "</span></td>";
                      html += "<td>" + project + "</td>";
                      html += "<td>" + mapLink + "</td>";
                      html += "<td>" + photoBtn + "</td>";
                      html += "</tr>";
                  });
                  
                  document.getElementById("tableBody").innerHTML = html;
                  document.getElementById("presentToday").innerText = actionCount; 
              });
        }

        // --- 4. UTILS ---
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

        function logout(){
            auth.signOut().then(() => window.location.href = "index.html");
        }
        
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("open");
        }
    </script>
</body>
</html>