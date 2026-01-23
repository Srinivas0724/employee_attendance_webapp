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
    <title>Attendance Reports - Synod Bioscience</title>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

    <style>
        /* --- 1. RESET & CORE THEME (Matches Admin) --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --sidebar-width: 280px;
            --card-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar { 
            width: var(--sidebar-width); 
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white; 
            display: flex; flex-direction: column; flex-shrink: 0; 
            transition: all 0.3s ease; z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }
        .sidebar-header { padding: 30px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); background: rgba(0,0,0,0.1); }
        .sidebar-logo { max-width: 130px; margin-bottom: 15px; filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2)); }
        .sidebar-brand { font-size: 13px; font-weight: 600; letter-spacing: 1.5px; text-transform: uppercase; opacity: 0.9; }
        
        .nav-menu { list-style: none; padding: 20px 15px; flex: 1; overflow-y: auto; }
        .nav-item { margin-bottom: 8px; }
        .nav-item a { display: flex; align-items: center; padding: 14px 20px; color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; border-radius: 10px; transition: all 0.2s; }
        .nav-item a:hover { background: rgba(255,255,255,0.08); color: white; transform: translateX(5px); }
        .nav-item a.active { background: var(--primary-green); color: white; box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4); }
        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }
        
        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout { width: 100%; padding: 14px; background: rgba(231, 76, 60, 0.9); color: white; border: none; border-radius: 10px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.2s; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-logout:hover { background: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; position: relative; }
        .topbar { background: white; height: 70px; display: flex; justify-content: space-between; align-items: center; padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); flex-shrink: 0; }
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        /* --- 4. LAYOUT & CONTROLS --- */
        .content { padding: 30px 40px; display: flex; flex-direction: column; gap: 25px; height: calc(100vh - 70px); overflow: hidden; }

        .card { background: white; padding: 25px; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; display: flex; align-items: center; gap: 15px; flex-shrink: 0; flex-wrap: wrap; }
        
        .control-group { display: flex; align-items: center; gap: 10px; background: #f9f9f9; padding: 8px 15px; border-radius: 8px; border: 1px solid #eee; }
        label { font-size: 12px; font-weight: 700; color: var(--text-dark); text-transform: uppercase; }
        select, input[type="date"] { border: none; background: transparent; font-family: inherit; font-size: 14px; outline: none; color: var(--text-dark); cursor: pointer; }

        .btn { padding: 10px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: 0.2s; color: white; }
        .btn-blue { background: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.2); }
        .btn-blue:hover { background: #132c52; transform: translateY(-2px); }
        .btn-green { background: #27ae60; margin-left: auto; box-shadow: 0 4px 10px rgba(39, 174, 96, 0.2); }
        .btn-green:hover { background: #219150; transform: translateY(-2px); }

        /* --- 5. REPORT TABLE (ORIGINAL DESIGN) --- */
        .table-wrapper { flex: 1; overflow: auto; background: white; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; position: relative; }
        
        table { width: 100%; border-collapse: separate; border-spacing: 0; min-width: 1000px; }
        
        /* Sticky Headers */
        th { background: #f8f9fa; padding: 15px 5px; text-align: center; font-size: 12px; color: var(--text-grey); font-weight: 700; border-bottom: 2px solid #eee; border-right: 1px solid #eee; position: sticky; top: 0; z-index: 10; }
        th:first-child { text-align: left; padding-left: 20px; min-width: 200px; z-index: 20; left: 0; background: #f8f9fa; border-right: 2px solid #eee; }

        /* Cells */
        td { padding: 5px; border-bottom: 1px solid #f9f9f9; border-right: 1px solid #f9f9f9; text-align: center; vertical-align: middle; height: 60px; min-width: 90px; }
        td:first-child { position: sticky; left: 0; z-index: 5; background: white; font-weight: 700; text-align: left; padding-left: 20px; color: var(--primary-navy); border-right: 2px solid #eee; font-size: 13px; }
        
        /* --- CELL STYLING (Solid Colors) --- */
        .cell-box { display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%; width: 100%; gap: 2px; cursor: pointer; border-radius: 4px; transition: 0.1s; }
        .cell-box:hover { filter: brightness(0.95); }

        .time-row { font-size: 10px; color: #333; white-space: nowrap; font-weight: 600; }
        .big-letter { font-size: 16px; font-weight: 800; opacity: 0.8; }
        .late-label { color: #c0392b; font-size: 9px; font-weight: 900; text-transform: uppercase; margin-bottom: 2px; letter-spacing: 0.5px; }
        .auto-tag { color: #e65100; font-size: 9px; font-style: italic; }

        /* Status Classes (Solid Backgrounds) */
        .P { background-color: #e8f5e9; color: #1b5e20; } /* Present Green */
        .A { background-color: #ffebee; color: #b71c1c; } /* Absent Red */
        .WO { background-color: #e3f2fd; color: #0d47a1; } /* Week Off Blue */
        .L { background-color: #fff8e1; color: #e65100; } /* Late Yellow/Orange */
        .HO { background-color: #f3e5f5; color: #4a148c; } /* Holiday Purple */
        .Future { background-color: white; color: #eee; font-size: 20px; font-weight: bold; }

        /* --- 6. MODAL --- */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(3px); justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 16px; width: 380px; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
        .modal-header { font-size: 18px; font-weight: 700; margin-bottom: 20px; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        
        .input-wrap { margin-bottom: 15px; }
        .input-wrap label { display: block; margin-bottom: 6px; }
        .input-wrap input, .input-wrap select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; background: #fcfcfc; font-size: 14px; }
        
        .modal-actions { margin-top: 25px; display: flex; gap: 10px; }
        .btn-modal { flex: 1; padding: 12px; border: none; border-radius: 8px; cursor: pointer; font-weight: 700; font-size: 13px; color: white; transition: 0.2s; }
        .btn-save { background: var(--primary-navy); } 
        .btn-reset { background: #e74c3c; } 
        .btn-cancel { background: #95a5a6; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; font-size: 20px; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px; margin-bottom: 15px;">📊</div>
        <div>Generating Report...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a></li>
            <li class="nav-item"><a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a></li>
            <li class="nav-item"><a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a></li>
            <li class="nav-item"><a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a></li>
            <li class="nav-item"><a href="manager_report.jsp" class="active"><span class="nav-icon">📅</span> View Attendance</a></li>
            <li class="nav-item"><a href="manager_list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="manager_settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a></li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Attendance Reports</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            
            <div class="card">
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
                <div class="control-group">
                    <label>From:</label>
                    <input type="date" id="startDate">
                    <label>To:</label>
                    <input type="date" id="endDate">
                </div>
                
                <button class="btn btn-blue" onclick="generateReport()">🔄 Generate</button>
                <button class="btn btn-green" onclick="exportToExcel()">📥 Export Excel</button>
            </div>

            <div class="table-wrapper">
                <table id="reportTable">
                    <thead id="tableHead"></thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">Edit Attendance Record</div>
            
            <input type="hidden" id="modalEmpEmail">
            <input type="hidden" id="modalDateValue">
            
            <div class="input-wrap">
                <label>Employee Name</label>
                <input type="text" id="modalEmpName" disabled style="color:#777;">
            </div>
            
            <div class="input-wrap">
                <label>Selected Date</label>
                <input type="text" id="modalDateDisplay" disabled style="color:#777;">
            </div>
            
            <div class="input-wrap">
                <label>Override Status</label>
                <select id="modalStatus">
                    <option value="P">Present (P)</option>
                    <option value="A">Absent (A)</option>
                    <option value="WO">Week Off (WO)</option>
                    <option value="HO">Holiday (HO)</option>
                </select>
            </div>

            <div class="modal-actions">
                <button onclick="saveManual()" class="btn-modal btn-save">Save Change</button>
                <button onclick="resetManual()" class="btn-modal btn-reset">Reset to Auto</button>
                <button onclick="closeModal()" class="btn-modal btn-cancel">Cancel</button>
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

        let manualData = {};
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // INIT
        window.onload = function() {
            const monthSel = document.getElementById("monthSelect");
            monthNames.forEach((m, i) => {
                let opt = new Option(m, i);
                if(i === new Date().getMonth()) opt.selected = true;
                monthSel.add(opt);
            });

            const today = new Date();
            document.getElementById("startDate").valueAsDate = new Date(today.getFullYear(), today.getMonth(), 1);
            document.getElementById("endDate").valueAsDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);

            auth.onAuthStateChanged(user => {
                if(user) {
                    db.collection("users").doc(user.email).get().then(doc => {
                        const role = doc.data().role;
                        if(role === 'admin' || role === 'manager') {
                            document.getElementById("adminEmail").innerText = user.email;
                            if(role==='manager') document.querySelector('.sidebar-brand').innerText = "MANAGER PORTAL";
                            generateReport();
                        } else window.location.href = "index.html";
                    });
                } else window.location.href = "index.html";
            });
        };

        async function generateReport() {
            const startVal = document.getElementById("startDate").value;
            const endVal = document.getElementById("endDate").value;
            document.getElementById("loadingOverlay").style.display = "flex";

            const dates = getDates(new Date(startVal), new Date(endVal));
            
            // HEADER (Simple Numbers)
            let headRow = "<tr><th>EMPLOYEE NAME</th>";
            dates.forEach(d => headRow += "<th>" + d.getDate() + "</th>");
            headRow += "</tr>";
            document.getElementById("tableHead").innerHTML = headRow;

            // DATA FETCH
            const [usersSnap, attSnap, manSnap] = await Promise.all([
                db.collection("users").where("role", "!=", "admin").get(),
                db.collection("attendance_2025").where("timestamp", ">=", new Date(startVal)).where("timestamp", "<=", new Date(new Date(endVal).setHours(23,59,59))).get(),
                db.collection("attendance_manual").get()
            ]);

            // PROCESS DATA
            let attMap = {};
            attSnap.forEach(doc => {
                const d = doc.data();
                const key = d.email + "_" + new Date(d.timestamp.seconds*1000).toDateString();
                if(!attMap[key]) attMap[key] = { in: null, out: null };
                
                const timeStr = new Date(d.timestamp.seconds*1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                if(d.type === 'IN') {
                    if(!attMap[key].in || d.timestamp.seconds < attMap[key].in.seconds) attMap[key].in = { time: timeStr, obj: d.timestamp };
                } else {
                    if(!attMap[key].out || d.timestamp.seconds > attMap[key].out.seconds) attMap[key].out = { time: timeStr };
                }
            });

            manualData = {};
            manSnap.forEach(doc => manualData[doc.id] = doc.data().status);

            // BUILD ROWS
            let rowsHtml = "";
            usersSnap.forEach(uDoc => {
                const u = uDoc.data();
                const shifts = u.shiftTimings || {};
                let row = "<tr><td>" + (u.fullName || uDoc.id) + "</td>";

                dates.forEach(d => {
                    const dateKey = uDoc.id + "_" + d.toDateString();
                    const isoDate = d.toISOString().split('T')[0];
                    const manualId = uDoc.id + "_" + isoDate;
                    const clickAction = "openEdit('" + uDoc.id + "', '" + (u.fullName || '').replace(/'/g, "\\'") + "', '" + isoDate + "')";

                    let cellHtml = "";
                    let cellClass = "";

                    // 1. Manual Override
                    if(manualData[manualId]) {
                        const s = manualData[manualId];
                        cellClass = s; 
                        
                        if(s === 'P') {
                            cellHtml = "<div class='cell-box'><span class='time-row'>Manual</span></div>";
                        } else {
                            cellHtml = "<div class='cell-box'><span class='big-letter'>" + s + "</span></div>";
                        }
                    } 
                    // 2. Auto Logic
                    else {
                        const dayName = d.toLocaleDateString('en-US', {weekday: 'short'});
                        const shiftStart = shifts[dayName] || "09:30";
                        const isOff = (shiftStart === "OFF" || dayName === "Sun");

                        if(isOff) {
                            cellClass = "WO";
                            cellHtml = "<div class='cell-box'><span class='big-letter'>WO</span></div>";
                        } else if(d > new Date()) {
                            cellHtml = "<div class='cell-box'><span class='Future'>-</span></div>";
                        } else {
                            const mapKey = uDoc.id + "_" + d.toDateString();
                            const record = attMap[mapKey];

                            if(record && record.in) {
                                // PRESENT or LATE
                                const inTime = record.in.time;
                                let outTime = record.out ? record.out.time : "--:--";
                                
                                // Auto Clock Out Visual
                                const todayZero = new Date(); todayZero.setHours(0,0,0,0);
                                if (!record.out && d < todayZero) {
                                    outTime = "06:00 PM <span class='auto-tag'></span>";
                                }

                                // Check Late
                                const inDateObj = new Date(record.in.obj.seconds * 1000);
                                const [sH, sM] = shiftStart.split(":").map(Number);
                                let isLate = false;
                                if(inDateObj.getHours() > sH || (inDateObj.getHours() === sH && inDateObj.getMinutes() > sM)) isLate = true;

                                cellClass = isLate ? "L" : "P";
                                let label = isLate ? "<div class='late-label'>LATE</div>" : "";
                                
                                cellHtml = "<div class='cell-box'>" + label + 
                                           "<div class='time-row'>IN: " + inTime + "</div>" +
                                           "<div class='time-row'>OUT: " + outTime + "</div></div>";
                            } else {
                                // ABSENT
                                cellClass = "A";
                                cellHtml = "<div class='cell-box'><span class='big-letter'>A</span></div>";
                            }
                        }
                    }
                    
                    row += "<td class='" + cellClass + "' onclick=\"" + clickAction + "\">" + cellHtml + "</td>";
                });
                row += "</tr>";
                rowsHtml += row;
            });

            document.getElementById("tableBody").innerHTML = rowsHtml;
            document.getElementById("loadingOverlay").style.display = "none";
        }

        function getDates(startDate, stopDate) {
            var dateArray = [];
            var currentDate = startDate;
            while (currentDate <= stopDate) {
                dateArray.push(new Date (currentDate));
                currentDate.setDate(currentDate.getDate() + 1);
            }
            return dateArray;
        }

        // --- MODAL & ACTIONS ---
        function openEdit(email, name, dateStr) {
            document.getElementById("modalEmpName").value = name;
            document.getElementById("modalEmpEmail").value = email;
            document.getElementById("modalDateDisplay").value = dateStr;
            document.getElementById("modalDateValue").value = dateStr;
            document.getElementById("editModal").style.display = "flex";
        }
        function closeModal() { document.getElementById("editModal").style.display = "none"; }

        function saveManual() {
            const email = document.getElementById("modalEmpEmail").value;
            const dateStr = document.getElementById("modalDateValue").value;
            const status = document.getElementById("modalStatus").value;
            const docId = email + "_" + dateStr;

            db.collection("attendance_manual").doc(docId).set({
                email, dateString: dateStr, status,
                updatedBy: auth.currentUser.email, timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { generateReport(); closeModal(); });
        }

        function resetManual() {
            if(!confirm("Reset to auto?")) return;
            const email = document.getElementById("modalEmpEmail").value;
            const dateStr = document.getElementById("modalDateValue").value;
            const docId = email + "_" + dateStr;
            db.collection("attendance_manual").doc(docId).delete().then(() => { generateReport(); closeModal(); });
        }

        function exportToExcel() {
            var wb = XLSX.utils.table_to_book(document.getElementById('reportTable'), {sheet:"Attendance"});
            XLSX.writeFile(wb, 'Attendance_Report.xlsx');
        }

        function logout() { auth.signOut().then(() => window.location.href="index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
    </script>
</body>
</html>