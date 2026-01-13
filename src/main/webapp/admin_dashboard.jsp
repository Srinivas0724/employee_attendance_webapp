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
    <title>Live Dashboard - Synod Bioscience</title>
    
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

    <style>
        /* --- 1. RESET & CORE VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root { 
            --primary-navy: #1a3b6e; 
            --primary-dark: #122b52;
            --primary-green: #2ecc71; 
            --bg-light: #f0f2f5; 
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --sidebar-width: 280px; 
            --danger: #e74c3c;
            --warning: #f39c12;
            --info: #3498db;
            --card-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }
        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR (Matching Manager Style) --- */
        .sidebar { 
            width: var(--sidebar-width); 
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white; 
            display: flex; flex-direction: column; flex-shrink: 0; 
            box-shadow: 4px 0 20px rgba(0,0,0,0.1); z-index: 1000;
            transition: all 0.3s ease;
        }
        .sidebar-header { padding: 30px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); background: rgba(0,0,0,0.1); }
        .sidebar-logo { max-width: 130px; margin-bottom: 15px; filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2)); }
        .sidebar-brand { font-size: 13px; font-weight: 600; letter-spacing: 1.5px; opacity: 0.9; text-transform: uppercase; }
        
        .nav-menu { list-style: none; padding: 20px 15px; flex: 1; overflow-y: auto; }
        .nav-item { margin-bottom: 8px; }
        .nav-item a { display: flex; align-items: center; padding: 14px 20px; color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; border-radius: 10px; transition: all 0.2s ease; }
        .nav-item a:hover { background: rgba(255,255,255,0.08); color: white; transform: translateX(5px); }
        .nav-item a.active { background: var(--primary-green); color: white; box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4); }
        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }
        
        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout { width: 100%; padding: 14px; background: rgba(231, 76, 60, 0.9); color: white; border: none; border-radius: 10px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.2s; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-logout:hover { background: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; position: relative; }
        .topbar { background: white; height: 70px; display: flex; justify-content: space-between; align-items: center; padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); z-index: 50; }
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-email { font-size: 13px; color: var(--text-dark); font-weight: 600; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        .content { padding: 30px 40px; height: 100%; display: flex; flex-direction: column; gap: 30px; overflow-y: auto; }

        /* --- 4. STATS CARDS --- */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px; margin-bottom: 10px; }
        
        .stat-card { background: white; padding: 25px; border-radius: 16px; box-shadow: var(--card-shadow); display: flex; align-items: center; justify-content: space-between; transition: transform 0.2s; border-left: 5px solid transparent; }
        .stat-card:hover { transform: translateY(-5px); }
        
        .stat-info h3 { margin: 0; font-size: 13px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-info .number { margin-top: 5px; font-size: 32px; font-weight: 800; color: var(--text-dark); }
        .stat-icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 28px; }
        
        .border-blue { border-left-color: var(--info); }
        .border-blue .stat-icon { background: #e3f2fd; color: var(--info); }
        
        .border-green { border-left-color: var(--secondary); }
        .border-green .stat-icon { background: #e8f5e9; color: var(--secondary); }
        
        .border-orange { border-left-color: var(--warning); }
        .border-orange .stat-icon { background: #fff3cd; color: var(--warning); }

        /* --- 5. TABLE CARD --- */
        .table-card { background: white; border-radius: 16px; box-shadow: var(--card-shadow); padding: 30px; display: flex; flex-direction: column; flex: 1; overflow: hidden; border: 1px solid #f1f1f1; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .table-header h3 { font-size: 18px; font-weight: 700; color: var(--primary-navy); margin: 0; }
        
        .live-badge { background: #ffebee; color: #c0392b; padding: 6px 15px; border-radius: 20px; font-size: 12px; font-weight: 800; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 8px rgba(231, 76, 60, 0.2); }
        .live-dot { width: 8px; height: 8px; background: #c0392b; border-radius: 50%; animation: pulse 1.5s infinite; }
        
        @keyframes pulse { 0% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(1.2); } 100% { opacity: 1; transform: scale(1); } }

        /* Table */
        .table-wrapper { flex: 1; overflow-y: auto; border-radius: 8px; border: 1px solid #f1f1f1; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; }
        
        th { background: #f8f9fa; position: sticky; top: 0; padding: 15px; text-align: left; font-size: 13px; font-weight: 600; color: var(--text-grey); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #eee; z-index: 10; }
        td { padding: 15px; border-bottom: 1px solid #f8f9fa; font-size: 14px; color: var(--text-dark); vertical-align: middle; }
        tr:hover td { background-color: #fcfcfc; }

        /* Badges & Buttons */
        .status-badge { padding: 6px 12px; border-radius: 30px; font-size: 12px; font-weight: 700; display: inline-block; }
        .badge-in { background: #e8f5e9; color: #27ae60; }
        .badge-out { background: #ffebee; color: #c0392b; }

        .btn-view { background: white; color: var(--primary-navy); border: 1px solid var(--primary-navy); padding: 6px 14px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; transition: all 0.2s; }
        .btn-view:hover { background: var(--primary-navy); color: white; }

        /* --- 6. MODAL --- */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 2000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 25px; border-radius: 16px; max-width: 450px; width: 90%; text-align: center; position: relative; box-shadow: 0 20px 50px rgba(0,0,0,0.3); }
        .modal img { max-width: 100%; border-radius: 10px; margin-top: 15px; border: 4px solid #f1f1f1; }
        .modal h4 { margin: 0; color: var(--primary-navy); font-size: 18px; }
        .close-btn { position: absolute; top: 15px; right: 15px; background: #f1f1f1; border: none; width: 32px; height: 32px; border-radius: 50%; cursor: pointer; font-size: 18px; color: #666; transition: 0.2s; }
        .close-btn:hover { background: #e74c3c; color: white; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column; color: var(--primary-navy); font-weight: 600; gap: 15px; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .stats-grid { grid-template-columns: 1fr; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📊</div>
        <div>Loading Live Data...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a></li>
            <li class="nav-item"><a href="admin_dashboard.jsp" class="active"><span class="nav-icon">📊</span> Live Dashboard</a></li>
            <li class="nav-item"><a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a></li>
            <li class="nav-item"><a href="list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a></li>
            <li class="nav-item"><a href="payroll.jsp"><span class="nav-icon">💰</span> Payroll</a></li>
            <li class="nav-item"><a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a></li>
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
                <span id="adminEmail" class="user-email">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            
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
                        <h3>Active Today</h3>
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
                    <div class="live-badge"><div class="live-dot"></div> LIVE FEED</div>
                </div>
                
                <div class="table-wrapper">
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
                            <tr><td colspan="6" style="text-align:center; padding:30px; color:#999;">Waiting for updates...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <div id="photoModal" class="modal" onclick="closeModal()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <button class="close-btn" onclick="closeModal()">×</button>
            <h4>Selfie Verification</h4>
            <img id="modalImg" src="" alt="User Selfie">
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
                        window.location.replace("index.html");
                    }
                });
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. DATA LOADING ---
        function loadDashboardData() {
            // Employee Count
            db.collection("users").where("role", "!=", "admin").get().then(snap => {
                document.getElementById("totalEmp").innerText = snap.size;
            });

            // Pending Approvals
            db.collection("users").where("status", "==", "Pending").get().then(snap => {
                document.getElementById("pendingCount").innerText = snap.size;
            });

            // Live Feed
            db.collection("attendance_2025")
              .orderBy("timestamp", "desc")
              .limit(15) 
              .onSnapshot(snapshot => {
                  let actionCount = 0;
                  let html = "";
                  allRecords = []; 

                  if(snapshot.empty) {
                      document.getElementById("tableBody").innerHTML = "<tr><td colspan='6' style='text-align:center; padding:30px; color:#777;'>No attendance records found today.</td></tr>";
                      return;
                  }

                  snapshot.forEach(doc => {
                      const data = doc.data();
                      actionCount++;
                      allRecords.push(data);
                      const index = allRecords.length - 1;
                      
                      let time = data.timestamp ? new Date(data.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "N/A";
                      const type = data.type || "UNKNOWN";
                      const badgeClass = (type === "IN") ? "badge-in" : "badge-out";
                      
                      let mapLink = "<span style='color:#ccc'>No GPS</span>";
                      if(data.location && data.location.lat) {
                          // Fixed String Concatenation for map link
                          mapLink = "<a href='https://www.google.com/maps?q=" + data.location.lat + "," + data.location.lng + "' target='_blank' style='color:#3498db; text-decoration:none; font-weight:700;'>📍 View Map</a>";
                      }

                      let photoBtn = "<span style='color:#ccc; font-size:12px'>No Pic</span>";
                      if (data.photo) {
                           // Fixed String Concatenation for onclick
                           photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>📷 View</button>";
                      }

                      // Concatenating HTML string properly
                      html += "<tr>";
                      html += "<td><b>" + time + "</b></td>";
                      html += "<td>" + (data.email || "Unknown") + "</td>";
                      html += "<td><span class='status-badge " + badgeClass + "'>" + type + "</span></td>";
                      html += "<td>" + (data.project || "General") + "</td>";
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

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        function logout(){
            auth.signOut().then(() => window.location.href = "index.html");
        }
    </script>
</body>
</html>