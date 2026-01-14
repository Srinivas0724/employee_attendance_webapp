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
    <title>Attendance Report - Manager Portal</title>
    
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

        /* --- 4. REPORT CONTENT --- */
        .content { padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 20px; }

        /* Controls Panel */
        .controls { 
            background: white; padding: 25px 30px; border-radius: 16px; 
            display: flex; gap: 25px; align-items: center; 
            box-shadow: var(--card-shadow); 
            border-top: 4px solid var(--primary-navy);
        }
        
        .control-group { display: flex; align-items: center; gap: 10px; }
        .control-group label { font-weight: 600; color: var(--text-dark); font-size: 14px; }
        
        select { 
            padding: 10px 15px; border: 1px solid #e0e0e0; 
            border-radius: 8px; font-size: 14px; outline: none; 
            background: #fdfdfd; cursor: pointer; transition: 0.3s;
        }
        select:focus { border-color: var(--primary-navy); background: white; }
        
        .btn-refresh { 
            padding: 10px 25px; background: #3498db; color: white; border: none; 
            border-radius: 8px; cursor: pointer; font-weight: 600; transition: all 0.2s; 
            font-size: 14px;
        }
        .btn-refresh:hover { background: #2980b9; transform: translateY(-2px); }
        
        .btn-export { 
            padding: 10px 25px; background: #27ae60; color: white; border: none; 
            border-radius: 8px; cursor: pointer; font-weight: 600; 
            margin-left: auto; transition: all 0.2s; font-size: 14px;
        }
        .btn-export:hover { background: #219150; transform: translateY(-2px); }

        /* Legend */
        .legend { 
            display: flex; gap: 20px; margin-bottom: 5px; 
            font-size: 13px; color: var(--text-grey); font-weight: 500;
        }
        .legend-item { display: flex; align-items: center; gap: 8px; }
        .dot { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }

        /* Sheet Container */
        .sheet-container { 
            flex: 1; overflow: auto; background: white; 
            border-radius: 16px; box-shadow: var(--card-shadow); 
            position: relative; max-height: 65vh;
        }
        
        table { border-collapse: separate; border-spacing: 0; min-width: 100%; }
        
        /* Cells */
        th, td { 
            border-right: 1px solid #f1f1f1; border-bottom: 1px solid #f1f1f1; 
            padding: 12px 8px; text-align: center; font-size: 13px; 
            white-space: nowrap; vertical-align: middle; 
            height: 55px;
        }

        /* Sticky Headers */
        th { 
            background: var(--primary-navy); color: white; 
            position: sticky; top: 0; z-index: 10; 
            height: 50px; font-weight: 600; 
            text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px;
            border-right: 1px solid rgba(255,255,255,0.1);
        }
        
        /* Sticky First Column (Names) */
        td:first-child, th:first-child { 
            position: sticky; left: 0; z-index: 11; 
            background: #fff; 
            border-right: 2px solid #e0e0e0; 
            font-weight: 700; text-align: left; 
            min-width: 200px; padding-left: 20px; color: var(--primary-navy);
        }
        th:first-child { z-index: 12; background: var(--primary-navy); color: white; }

        /* Row Hover */
        tr:hover td { background-color: #f8f9fa; }
        tr:hover td:first-child { background-color: #f8f9fa; }

        /* Status Colors (Subtler) */
        .P { background-color: #f0fdf4; color: #166534; font-weight: 500; } /* Green */
        .A { background-color: #fef2f2; color: #991b1b; font-weight: 600; } /* Red */
        .L { background-color: #fffbeb; color: #b45309; font-weight: 600; } /* Orange */
        .H { background-color: #f9fafb; color: #9ca3af; } /* Grey */
        .OFF { background-color: #eff6ff; color: #1e40af; font-size: 11px; font-weight: 600; } /* Blue */

        /* Text inside cells */
        .time-box { display: flex; flex-direction: column; justify-content: center; line-height: 1.4; font-size: 11px; }
        .late-badge { color: #d97706; font-weight: 800; font-size: 10px; display: block; text-transform: uppercase; }

        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.9); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .controls { flex-direction: column; align-items: stretch; }
            .btn-export { margin-left: 0; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.0/xlsx.full.min.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📅</div>
        <div>Generating Report...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a>
            </li>
            <li class="nav-item">
                <a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a>
            </li>
            <li class="nav-item">
                <a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a>
            </li>
            <li class="nav-item">
                <a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a>
            </li>
            <li class="nav-item">
                <a href="manager_report.jsp" class="active"><span class="nav-icon">📅</span> View Attendance</a>
            </li>
            <li class="nav-item">
                <a href="manager_settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a>
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
                <div class="page-title">Monthly Attendance</div>
            </div>
            <div class="user-profile">
                <span id="mgrEmail" class="user-email">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">
            
            <div class="controls">
                <div class="control-group">
                    <label>Month:</label>
                    <select id="monthSelect"></select>
                </div>
                
                <div class="control-group">
                    <label>Year:</label>
                    <select id="yearSelect">
                        <option value="2024">2024</option>
                        <option value="2025" selected>2025</option>
                        <option value="2026">2026</option>
                    </select>
                </div>
                
                <button onclick="generateReport()" class="btn-refresh">🔄 Refresh Data</button>
                <button class="btn-export" onclick="exportToExcel()">📥 Download Excel</button>
            </div>

            <div class="legend">
                <div class="legend-item"><span class="dot" style="background:#d4edda;"></span> Present</div>
                <div class="legend-item"><span class="dot" style="background:#fff8e1;"></span> Late</div>
                <div class="legend-item"><span class="dot" style="background:#ffebee;"></span> Absent</div>
                <div class="legend-item"><span class="dot" style="background:#e3f2fd;"></span> Weekly Off</div>
            </div>

            <div class="sheet-container">
                <table id="attendanceTable">
                    <thead><tr id="tableHeader"><th>Employee Name</th></tr></thead>
                    <tbody id="tableBody"></tbody>
                </table>
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

        let allUsers = [];
        let attendanceData = [];
        const daysMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        const monthSelect = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            const opt = document.createElement("option");
            opt.value = i; 
            opt.text = m;
            if(i === new Date().getMonth()) opt.selected = true;
            monthSelect.add(opt);
        });

        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    if (role !== 'manager' && role !== 'admin') {
                        window.location.href = "login.jsp";
                        return;
                    } 
                    document.getElementById("mgrEmail").innerText = user.email;
                    fetchUsersAndReport();
                });
            } else {
                window.location.replace("index.html");
            }
        });

        function fetchUsersAndReport() {
            document.getElementById("loadingOverlay").style.display = "flex";
            
            db.collection("users").get().then(userSnap => {
                allUsers = [];
                userSnap.forEach(doc => {
                    const d = doc.data();
                    if(d.role !== 'admin') {
                        allUsers.push({
                            email: (d.email || "").toLowerCase(), 
                            name: d.fullName || d.email || "Unknown",
                            shifts: d.shiftTimings || {} 
                        });
                    }
                });
                
                allUsers.sort(function(a, b) {
                    return (a.name || "").localeCompare(b.name || "");
                });
                generateReport();
            }).catch(e => {
                alert("Error: " + e.message);
                document.getElementById("loadingOverlay").style.display = "none";
            });
        }

        function generateReport() {
            const month = parseInt(document.getElementById("monthSelect").value);
            const year = parseInt(document.getElementById("yearSelect").value);
            const start = new Date(year, month, 1);
            const end = new Date(year, month + 1, 0, 23, 59, 59);

            document.getElementById("loadingOverlay").style.display = "flex";

            const collectionName = "attendance_2025"; 

            db.collection(collectionName)
                .where("timestamp", ">=", start)
                .where("timestamp", "<=", end)
                .get()
                .then(snap => {
                    attendanceData = [];
                    snap.forEach(doc => {
                        const d = doc.data();
                        if(d.email) d.email = d.email.toLowerCase();
                        attendanceData.push(d);
                    });
                    renderTable(month, year);
                    document.getElementById("loadingOverlay").style.display = "none";
                })
                .catch(err => {
                    console.log("Error fetching data", err);
                    renderTable(month, year); 
                    document.getElementById("loadingOverlay").style.display = "none";
                });
        }

        function renderTable(month, year) {
            const daysInMonth = new Date(year, month + 1, 0).getDate();
            const tableHeader = document.getElementById("tableHeader");
            const tableBody = document.getElementById("tableBody");
            
            const today = new Date();
            today.setHours(0,0,0,0); 
            
            let headerHTML = "<th>Employee Name</th>";
            for(let i=1; i<=daysInMonth; i++) {
                headerHTML += "<th>" + i + "</th>";
            }
            tableHeader.innerHTML = headerHTML;

            let bodyHTML = "";

            allUsers.forEach(user => {
                bodyHTML += "<tr><td>" + user.name + "</td>";

                for(let d=1; d<=daysInMonth; d++) {
                    const colDate = new Date(year, month, d);
                    colDate.setHours(0,0,0,0); 
                    
                    if(colDate.getTime() > today.getTime()) {
                        bodyHTML += "<td class='H'>-</td>";
                        continue;
                    }

                    const dayName = daysMap[colDate.getDay()]; 
                    
                    let requiredTime = user.shifts[dayName];
                    if(!requiredTime && dayName === "Sun") requiredTime = "OFF";
                    if(!requiredTime) requiredTime = "09:30"; 

                    if (requiredTime === "OFF") {
                        bodyHTML += "<td class='OFF'>OFF</td>";
                        continue;
                    }

                    const dailyRecs = attendanceData.filter(function(a) {
                        if(!a.timestamp) return false;
                        const recDate = new Date(a.timestamp.seconds * 1000);
                        return a.email === user.email && recDate.getDate() === d;
                    });

                    const inRec = dailyRecs.find(function(r) { return r.type === 'IN'; });
                    const outRec = dailyRecs.find(function(r) { return r.type === 'OUT'; });

                    let cellClass = "";
                    let cellContent = "";

                    if (!inRec) {
                        cellClass = "A";
                        cellContent = "Absent";
                    } else {
                        const inTimeObj = new Date(inRec.timestamp.seconds * 1000);
                        const inTimeStr = inTimeObj.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', hour12: false});
                        
                        let outTimeStr = "--:--";
                        if(outRec) {
                            const outTimeObj = new Date(outRec.timestamp.seconds * 1000);
                            outTimeStr = outTimeObj.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', hour12: false});
                        }

                        const timeParts = requiredTime.split(":");
                        const reqH = parseInt(timeParts[0]);
                        const reqM = parseInt(timeParts[1]);
                        
                        const isLate = (inTimeObj.getHours() > reqH) || (inTimeObj.getHours() === reqH && inTimeObj.getMinutes() > reqM);

                        if(isLate) {
                            cellClass = "L";
                            cellContent = "<div class='time-box'><span class='late-badge'>LATE</span>" + inTimeStr + " - " + outTimeStr + "</div>";
                        } else {
                            cellClass = "P";
                            cellContent = "<div class='time-box'>" + inTimeStr + " - " + outTimeStr + "</div>";
                        }
                    }
                    bodyHTML += "<td class='" + cellClass + "'>" + cellContent + "</td>";
                }
                bodyHTML += "</tr>";
            });
            tableBody.innerHTML = bodyHTML;
        }

        function exportToExcel() {
            let exportData = [];
            const month = parseInt(document.getElementById("monthSelect").value);
            const year = parseInt(document.getElementById("yearSelect").value);
            const daysInMonth = new Date(year, month + 1, 0).getDate();

            allUsers.forEach(user => {
                let row = { "Employee": user.name };
                
                for(let d=1; d<=daysInMonth; d++) {
                      const dailyRecs = attendanceData.filter(function(a) {
                        if(!a.timestamp) return false;
                        const recDate = new Date(a.timestamp.seconds * 1000);
                        return a.email === user.email && recDate.getDate() === d;
                    });
                    
                    const inRec = dailyRecs.find(function(r) { return r.type === 'IN'; });
                    const outRec = dailyRecs.find(function(r) { return r.type === 'OUT'; });

                    if(inRec) {
                        const iTime = new Date(inRec.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                        const oTime = outRec ? new Date(outRec.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "--";
                        row[d] = iTime + " - " + oTime;
                    } else {
                        row[d] = "Absent";
                    }
                }
                exportData.push(row);
            });

            const ws = XLSX.utils.json_to_sheet(exportData);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Attendance");
            XLSX.writeFile(wb, "Attendance_Report.xlsx");
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>



