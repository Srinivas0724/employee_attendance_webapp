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
        /* --- 1. RESET & CORE THEME --- */
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
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; position: relative; }
        .topbar { background: white; height: 70px; display: flex; justify-content: space-between; align-items: center; padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); position: sticky; top: 0; z-index: 50; }
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        .content { padding: 30px 40px; max-width: 1600px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 20px; height: calc(100vh - 70px); }

        /* --- 4. CONTROLS CARD --- */
        .controls-card { background: white; padding: 20px 30px; border-radius: 16px; display: flex; gap: 20px; align-items: center; box-shadow: var(--card-shadow); flex-shrink: 0; border: 1px solid white; }
        
        .control-group { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 600; color: var(--text-dark); }
        select { padding: 10px 15px; border: 1px solid #e0e0e0; border-radius: 8px; outline: none; background: #f9f9f9; font-size: 14px; cursor: pointer; transition: 0.2s; }
        select:hover { background: #fff; border-color: var(--primary-navy); }

        .btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; color: white; display: flex; align-items: center; gap: 8px; font-size: 13px; transition: all 0.2s; }
        .btn:hover { transform: translateY(-2px); opacity: 0.9; }
        .btn-refresh { background: #3498db; box-shadow: 0 4px 10px rgba(52, 152, 219, 0.3); }
        .btn-excel { background: #27ae60; margin-left: auto; box-shadow: 0 4px 10px rgba(39, 174, 96, 0.3); }
        .btn-print { background: #f39c12; box-shadow: 0 4px 10px rgba(243, 156, 18, 0.3); }

        /* Legend */
        .legend { display: flex; gap: 25px; font-size: 12px; color: var(--text-grey); font-weight: 600; padding: 5px 10px; }
        .legend-item { display: flex; align-items: center; gap: 8px; }
        .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }

        /* --- 5. TABLE AREA --- */
        .table-container { flex: 1; overflow: auto; background: white; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; position: relative; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; }
        
        /* Sticky Header */
        th { background: #f8f9fa; color: var(--text-grey); position: sticky; top: 0; z-index: 10; height: 50px; font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 0 10px; border-bottom: 2px solid #eee; border-right: 1px solid #f0f0f0; }
        
        /* Cells */
        td { border-right: 1px solid #f9f9f9; border-bottom: 1px solid #f9f9f9; padding: 8px; text-align: center; font-size: 12px; white-space: nowrap; height: 65px; vertical-align: middle; min-width: 110px; }
        
        /* Sticky First Column */
        td:first-child, th:first-child { position: sticky; left: 0; z-index: 11; background: white; border-right: 2px solid #eee; font-weight: 700; text-align: left; padding-left: 20px; min-width: 200px; color: var(--primary-navy); }
        th:first-child { z-index: 12; background: #f8f9fa; }

        /* Hover */
        tr:hover td { background-color: #fcfcfc; }
        td.cell-clickable { cursor: pointer; transition: 0.1s; }
        td.cell-clickable:hover { background-color: #e3f2fd !important; outline: 2px solid var(--primary-navy); z-index: 5; }

        /* Status Colors (Subtle Pastels) */
        .P { background: #e8f5e9; color: #27ae60; }
        .A { background: #ffebee; color: #c0392b; font-weight: 700; }
        .L { background: #fff3cd; color: #d35400; }
        .WO { background: #e3f2fd; color: #2980b9; font-weight: 700; }
        .HO { background: #f3e5f5; color: #8e44ad; font-weight: 700; }
        .Future { background: white; color: #eee; }

        /* Cell Content */
        .time-box { display: flex; flex-direction: column; justify-content: center; gap: 3px; font-size: 11px; line-height: 1.2; }
        .time-row { font-family: monospace; letter-spacing: -0.5px; color: #444; }
        .late-badge { color: #c0392b; font-weight: 800; font-size: 9px; display: block; margin-bottom: 2px; text-transform: uppercase; }
        .manual-dot { width: 6px; height: 6px; background: #333; border-radius: 50%; position: absolute; top: 5px; right: 5px; }

        /* --- 6. MODAL --- */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 16px; width: 400px; box-shadow: 0 20px 50px rgba(0,0,0,0.2); }
        .modal-header { font-size: 18px; font-weight: 700; margin-bottom: 20px; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        
        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; margin-bottom: 6px; font-size: 12px; font-weight: 700; color: var(--text-dark); text-transform: uppercase; }
        .input-group input, .input-group select { width: 100%; padding: 12px; border: 1px solid #e0e0e0; border-radius: 8px; background: #f9f9f9; font-size: 14px; }
        
        .modal-actions { margin-top: 25px; display: flex; gap: 10px; }
        .btn-modal { flex: 1; padding: 12px; border: none; border-radius: 8px; cursor: pointer; font-weight: 700; font-size: 13px; color: white; transition: 0.2s; }
        .btn-save { background: var(--primary-navy); }
        .btn-reset { background: #e74c3c; }
        .btn-cancel { background: #95a5a6; }

        /* --- PRINT --- */
        @media print {
            @page { size: landscape; margin: 5mm; }
            body { background: white; }
            .sidebar, .topbar, .controls-card, .legend, .modal, #loading { display: none !important; }
            .main-content { overflow: visible; height: auto; }
            .content { padding: 0; margin: 0; height: auto; overflow: visible; }
            .table-container { box-shadow: none; border: 1px solid #000; overflow: visible; height: auto; }
            table { width: 100%; font-size: 9px; border-collapse: collapse; }
            th, td { border: 1px solid #000 !important; padding: 4px; height: auto; color: #000 !important; }
            th { background: #ddd !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .manual-dot { display: none; }
            .P { background-color: #e8f5e9 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .A { background-color: #ffebee !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .WO { background-color: #e3f2fd !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }

        #loading { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loading">
        <div style="font-size: 50px;">📅</div>
        <div style="margin-top:15px;">Generating Report...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a></li>
            <li class="nav-item"><a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a></li>
            <li class="nav-item"><a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp" class="active"><span class="nav-icon">📅</span> Attendance</a></li>
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
                <div class="page-title">Attendance Reports</div>
            </div>
            <div class="user-profile">
                <span id="currentUserEmail">Checking auth...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            
            <div class="controls-card">
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
                <button onclick="fetchData()" class="btn btn-refresh">🔄 Refresh</button>
                <button onclick="window.print()" class="btn btn-print">🖨️ Print</button>
                <button onclick="exportToExcel()" class="btn btn-excel">📥 Excel</button>
            </div>

            <div class="legend">
                <div class="legend-item"><span class="dot P" style="background:#27ae60;"></span> Present</div>
                <div class="legend-item"><span class="dot L" style="background:#d35400;"></span> Late</div>
                <div class="legend-item"><span class="dot A" style="background:#c0392b;"></span> Absent</div>
                <div class="legend-item"><span class="dot WO" style="background:#2980b9;"></span> Week Off</div>
                <div class="legend-item"><span class="dot HO" style="background:#8e44ad;"></span> Holiday</div>
                <div style="margin-left:auto; color:var(--primary-navy);">* Click any cell to edit</div>
            </div>

            <div class="table-container">
                <table id="attendanceTable">
                    <thead><tr id="tableHeader"></tr></thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">Edit Record</div>
            
            <div class="input-group">
                <label>Employee Name</label>
                <input type="text" id="modalEmpName" disabled>
                <input type="hidden" id="modalEmpEmail">
            </div>

            <div class="input-group">
                <label>Date</label>
                <input type="text" id="modalDateDisplay" disabled>
                <input type="hidden" id="modalDateValue">
            </div>

            <div class="input-group">
                <label>Status Override</label>
                <select id="modalStatus">
                    <option value="P">Present (P)</option>
                    <option value="A">Absent (A)</option>
                    <option value="WO">Week Off (WO)</option>
                    <option value="HO">Holiday (HO)</option>
                </select>
            </div>

            <div class="modal-actions">
                <button onclick="saveManual()" class="btn-modal btn-save">Save</button>
                <button onclick="resetManual()" class="btn-modal btn-reset">Reset</button>
                <button onclick="closeModal()" class="btn-modal btn-cancel">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        // CONFIG
        const firebaseConfig = {
            apiKey: "AIzaSyBzdM77WwTSkxvF0lsxf2WLNLhjuGyNvQQ",
            authDomain: "attendancewebapp-ef02a.firebaseapp.com",
            projectId: "attendancewebapp-ef02a",
            storageBucket: "attendancewebapp-ef02a.firebasestorage.app",
            messagingSenderId: "734213881030",
            appId: "1:734213881030:web:bfdcee5a2ff293f87e6bc7"
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();
        const auth = firebase.auth();

        let allUsers = [];
        let autoData = [];
        let manualData = {};
        const daysMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // INIT
        const monthSel = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            let opt = new Option(m, i);
            if(i === new Date().getMonth()) opt.selected = true;
            monthSel.add(opt);
        });

        auth.onAuthStateChanged(user => {
            if(user) {
                document.getElementById("currentUserEmail").innerText = user.email;
                fetchData();
            } else {
                window.location.href = "index.html";
            }
        });

        // FETCH
        function fetchData() {
            document.getElementById("loading").style.display = "flex";
            const m = parseInt(monthSel.value);
            const y = parseInt(document.getElementById("yearSelect").value);
            const start = new Date(y, m, 1);
            const end = new Date(y, m + 1, 0, 23, 59, 59);

            Promise.all([
                db.collection("users").get(),
                db.collection("attendance_2025").where("timestamp", ">=", start).where("timestamp", "<=", end).get(),
                db.collection("attendance_manual").get()
            ]).then(([usersSnap, autoSnap, manualSnap]) => {
                
                allUsers = [];
                usersSnap.forEach(doc => {
                    const d = doc.data();
                    if(d.role !== 'admin') allUsers.push({ email: d.email, name: d.fullName || d.email, shifts: d.shiftTimings || {} });
                });
                allUsers.sort((a,b) => a.name.localeCompare(b.name));

                autoData = [];
                autoSnap.forEach(doc => autoData.push(doc.data()));

                manualData = {};
                manualSnap.forEach(doc => manualData[doc.id] = doc.data().status);

                renderTable(m, y);
                document.getElementById("loading").style.display = "none";
            });
        }

        // RENDER TABLE
        function renderTable(m, y) {
            const daysInM = new Date(y, m + 1, 0).getDate();
            const tHead = document.getElementById("tableHeader");
            const tBody = document.getElementById("tableBody");
            const today = new Date(); today.setHours(0,0,0,0);

            let hHtml = "<th>Employee Name</th>";
            for(let i=1; i<=daysInM; i++) hHtml += "<th>" + i + "</th>";
            tHead.innerHTML = hHtml;

            let bHtml = "";
            allUsers.forEach(user => {
                bHtml += "<tr><td>" + user.name + "</td>";
                
                for(let d=1; d<=daysInM; d++) {
                    const colDate = new Date(y, m, d);
                    colDate.setHours(0,0,0,0);
                    const dateStr = y + "-" + String(m+1).padStart(2,'0') + "-" + String(d).padStart(2,'0');
                    const manualId = user.email + "_" + dateStr;
                    const clickAct = "openEdit('" + user.email + "', '" + user.name.replace(/'/g, "\\'") + "', '" + dateStr + "')";

                    // 1. Manual
                    if(manualData[manualId]) {
                        const s = manualData[manualId];
                        bHtml += "<td class='cell-clickable " + s + "' onclick=\"" + clickAct + "\">" + s + "<div class='manual-dot'></div></td>";
                        continue;
                    }

                    // 2. Future
                    if(colDate > today) {
                        bHtml += "<td class='Future'>-</td>";
                        continue;
                    }

                    // 3. Auto
                    const dayName = daysMap[colDate.getDay()];
                    let reqTime = user.shifts[dayName] || "09:30";
                    if(dayName === "Sun" && !user.shifts[dayName]) reqTime = "OFF";

                    if(reqTime === "OFF") {
                        bHtml += "<td class='cell-clickable WO' onclick=\"" + clickAct + "\">WO</td>";
                        continue;
                    }

                    const records = autoData.filter(a => {
                        const rd = new Date(a.timestamp.seconds * 1000);
                        return a.email === user.email && rd.getDate() === d;
                    });
                    const inRec = records.find(r => r.type === 'IN');
                    const outRec = records.find(r => r.type === 'OUT');

                    if(inRec) {
                        const inT = new Date(inRec.timestamp.seconds * 1000);
                        const outT = outRec ? new Date(outRec.timestamp.seconds * 1000) : null;
                        const timeOpts = {hour:'2-digit', minute:'2-digit', hour12:true};
                        const inStr = inT.toLocaleTimeString([], timeOpts);
                        const outStr = outT ? outT.toLocaleTimeString([], timeOpts) : "--:--";

                        const [rH, rM] = reqTime.split(":").map(Number);
                        const isLate = (inT.getHours() > rH) || (inT.getHours() === rH && inT.getMinutes() > rM);
                        const cellClass = isLate ? 'L' : 'P';
                        const badge = isLate ? "<span class='late-badge'>LATE</span>" : "";

                        bHtml += "<td class='cell-clickable " + cellClass + "' onclick=\"" + clickAct + "\">" +
                                 "<div class='time-box'>" + badge + 
                                 "<div class='time-row'>IN: " + inStr + "</div>" +
                                 "<div class='time-row'>OUT: " + outStr + "</div>" +
                                 "</div></td>";
                    } else {
                        bHtml += "<td class='cell-clickable A' onclick=\"" + clickAct + "\">A</td>";
                    }
                }
                bHtml += "</tr>";
            });
            tBody.innerHTML = bHtml;
        }

        // MODAL
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
            }).then(() => {
                manualData[docId] = status;
                refreshView();
            });
        }

        function resetManual() {
            if(!confirm("Reset to auto calculation?")) return;
            const email = document.getElementById("modalEmpEmail").value;
            const dateStr = document.getElementById("modalDateValue").value;
            const docId = email + "_" + dateStr;
            
            db.collection("attendance_manual").doc(docId).delete().then(() => {
                delete manualData[docId];
                refreshView();
            });
        }

        function refreshView() {
            const m = parseInt(monthSel.value);
            const y = parseInt(document.getElementById("yearSelect").value);
            renderTable(m, y);
            closeModal();
        }

        function exportToExcel() {
            const wb = XLSX.utils.table_to_book(document.getElementById("attendanceTable"), {sheet:"Sheet1"});
            XLSX.writeFile(wb, "Attendance_Report.xlsx");
        }

        function logout() { auth.signOut().then(() => location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
    </script>
</body>
</html>