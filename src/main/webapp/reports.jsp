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
    <title>Attendance Reports - Synod Bioscience</title>
    
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

        /* --- 4. REPORT CONTENT --- */
        .content { padding: 20px; height: 100%; display: flex; flex-direction: column; }

        /* Controls Panel */
        .controls { 
            background: white; padding: 15px 25px; border-radius: 8px; 
            display: flex; gap: 20px; align-items: center; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px; 
        }
        
        .control-group { display: flex; align-items: center; gap: 10px; }
        .control-group label { font-weight: 600; color: #555; font-size: 14px; }
        select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; outline: none; }
        
        .btn-refresh { padding: 8px 20px; background: #3498db; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; transition: 0.2s; }
        .btn-refresh:hover { background: #2980b9; transform: translateY(-1px); }
        
        .btn-export { padding: 8px 20px; background: #27ae60; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; margin-left: auto; transition: 0.2s; }
        .btn-export:hover { background: #219150; transform: translateY(-1px); }

        /* Legend */
        .legend { display: flex; gap: 15px; margin-bottom: 10px; font-size: 12px; color: #666; margin-left: 5px; }
        .legend-item { display: flex; align-items: center; gap: 5px; }
        .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }

        /* Sheet Container */
        .sheet-container { flex: 1; overflow: auto; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); position: relative; }
        
        table { border-collapse: separate; border-spacing: 0; min-width: 100%; }
        
        /* Cells */
        th, td { 
            border-right: 1px solid #eee; border-bottom: 1px solid #eee; 
            padding: 8px 5px; text-align: center; font-size: 12px; 
            white-space: nowrap; vertical-align: middle; 
            height: 50px;
        }

        /* Sticky Headers */
        th { 
            background: var(--primary-navy); color: white; 
            position: sticky; top: 0; z-index: 10; 
            height: 45px; font-weight: 600; 
            border-right: 1px solid rgba(255,255,255,0.1);
        }
        
        /* Sticky First Column (Names) */
        td:first-child, th:first-child { 
            position: sticky; left: 0; z-index: 11; 
            background: #fdfdfd; 
            border-right: 2px solid #ddd; 
            font-weight: 600; text-align: left; 
            width: 180px; padding-left: 15px; color: #333;
        }
        th:first-child { z-index: 12; background: var(--primary-navy); color: white; }

        /* Row Hover */
        tr:hover td { background-color: #f1f7ff; }
        tr:hover td:first-child { background-color: #eef5fc; }

        /* Status Colors (Subtler) */
        .P { background-color: #e8f5e9; color: #1b5e20; } /* Light Green */
        .A { background-color: #ffebee; color: #b71c1c; } /* Light Red */
        .L { background-color: #fff8e1; color: #f57f17; } /* Light Orange */
        .H { background-color: #f5f5f5; color: #9e9e9e; } /* Grey */
        .OFF { background-color: #e3f2fd; color: #1565c0; font-size: 10px; } /* Blueish for Weekly Off */

        /* Text inside cells */
        .time-box { display: flex; flex-direction: column; justify-content: center; line-height: 1.3; font-size: 11px; }
        .sub-text { font-size: 9px; opacity: 0.7; }
        .late-badge { color: #d32f2f; font-weight: bold; font-size: 10px; display: block; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.0/xlsx.full.min.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">📅</div>
        <div>Generating Report...</div>
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
                <a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a>
            </li>
            <li class="nav-item">
                <a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a>
            </li>
            <li class="nav-item">
                <a href="admin_attendance.jsp" class="active"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a>
            </li>
             <li class="nav-item">
                <a href="payroll.jsp" class="active"><span class="nav-icon">💰</span> Payroll</a>
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
                <div class="page-title">Monthly Attendance</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
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
                
                <button onclick="generateReport()" class="btn-refresh">🔄 Refresh Report</button>
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

        let allUsers = [];
        let attendanceData = [];
        const daysMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

        // Setup Month Dropdown
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        const monthSelect = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            const opt = document.createElement("option");
            opt.value = i; 
            opt.text = m;
            if(i === new Date().getMonth()) opt.selected = true;
            monthSelect.add(opt);
        });

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if(user) {
                document.getElementById("adminEmail").innerText = user.email;
                fetchUsersAndReport();
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. LOAD DATA ---
        function fetchUsersAndReport() {
            document.getElementById("loadingOverlay").style.display = "flex";
            
            db.collection("users").get().then(userSnap => {
                allUsers = [];
                userSnap.forEach(doc => {
                    const d = doc.data();
                    if(d.role !== 'admin') {
                        allUsers.push({
                            email: (d.email || "").toLowerCase(), // Store Lowercase for safe matching
                            name: d.fullName || d.email || "Unknown",
                            shifts: d.shiftTimings || {} 
                        });
                    }
                });
                // Sort Alphabetically
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

            // ⚠️ Using fixed 'attendance_2025' because your data is there (per screenshot)
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

        // --- 4. RENDER TABLE ---
        function renderTable(month, year) {
            const daysInMonth = new Date(year, month + 1, 0).getDate();
            const tableHeader = document.getElementById("tableHeader");
            const tableBody = document.getElementById("tableBody");
            
            // "Today" for future checking (Compare Start of Day)
            const today = new Date();
            today.setHours(0,0,0,0); 
            
            // Header
            let headerHTML = "<th>Employee Name</th>";
            for(let i=1; i<=daysInMonth; i++) {
                headerHTML += "<th>" + i + "</th>";
            }
            tableHeader.innerHTML = headerHTML;

            // Body
            let bodyHTML = "";

            allUsers.forEach(user => {
                bodyHTML += "<tr><td>" + user.name + "</td>";

                for(let d=1; d<=daysInMonth; d++) {
                    const colDate = new Date(year, month, d);
                    colDate.setHours(0,0,0,0); // Start of the column date
                    
                    // Future Check: If column date is AFTER today
                    if(colDate.getTime() > today.getTime()) {
                        bodyHTML += "<td class='H'>-</td>";
                        continue;
                    }

                    const dayName = daysMap[colDate.getDay()]; 
                    
                    // SHIFT LOGIC: Default Sun = OFF if undefined
                    let requiredTime = user.shifts[dayName];
                    if(!requiredTime && dayName === "Sun") requiredTime = "OFF";
                    if(!requiredTime) requiredTime = "09:30"; // Default start

                    // Holiday check
                    if (requiredTime === "OFF") {
                        bodyHTML += "<td class='OFF'>OFF</td>";
                        continue;
                    }

                    // Find records for this user & day
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

                        // Late Check
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

        // --- 5. EXPORT ---
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

        function logout(){ auth.signOut().then(() => location.href = "index.html"); }
        
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("open");
        }
    </script>
</body>
</html>