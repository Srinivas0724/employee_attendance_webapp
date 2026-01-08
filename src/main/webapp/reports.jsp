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
    <title>Attendance Report</title>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

    <style>
        /* --- RESET & BASICS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root { 
            --primary: #1a3b6e; 
            --secondary: #2ecc71; 
            --bg: #f4f6f9; 
            --sidebar-w: 260px; 
            --danger: #e74c3c;
        }
        body { display: flex; height: 100vh; background-color: var(--bg); overflow: hidden; }

        /* --- SIDEBAR --- */
        .sidebar { width: var(--sidebar-w); background-color: var(--primary); color: white; display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar-header { padding: 25px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-logo { max-width: 130px; margin-bottom: 10px; filter: brightness(0) invert(1); }
        .nav-menu { list-style: none; padding: 20px 0; flex: 1; overflow-y: auto; }
        .nav-item a { display: flex; align-items: center; padding: 15px 25px; color: #bdc3c7; text-decoration: none; border-left: 4px solid transparent; transition: 0.2s; font-size: 14px; }
        .nav-item a:hover, .nav-item a.active { background: rgba(255,255,255,0.1); color: white; border-left-color: var(--secondary); }
        .sidebar-footer { padding: 20px; }
        .btn-logout { width: 100%; padding: 12px; background: var(--danger); color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; }

        /* --- MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .topbar { background: white; height: 65px; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); z-index: 20; }
        .page-title { font-size: 20px; font-weight: 700; color: var(--primary); }
        .user-profile { font-size: 14px; color: #555; display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #eee; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary); }

        .content { padding: 25px; height: 100%; display: flex; flex-direction: column; overflow: hidden; gap: 15px; }

        /* --- CONTROLS --- */
        .controls-card { background: white; padding: 15px 25px; border-radius: 8px; display: flex; gap: 15px; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.03); flex-shrink: 0; }
        .control-group { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 600; color: #555; }
        select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; outline: none; background: #fff; }
        
        .btn { padding: 9px 18px; border: none; border-radius: 4px; cursor: pointer; font-weight: 600; color: white; display: flex; align-items: center; gap: 6px; font-size: 13px; transition: 0.2s; }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); }
        .btn-refresh { background: #3498db; }
        .btn-excel { background: #27ae60; margin-left: auto; }
        .btn-print { background: #f39c12; }

        /* --- LEGEND --- */
        .legend { display: flex; gap: 20px; font-size: 12px; color: #666; align-items: center; padding-left: 5px; }
        .legend-item { display: flex; align-items: center; gap: 6px; }
        .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }

        /* --- TABLE --- */
        .table-container { flex: 1; overflow: auto; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.03); border: 1px solid #eee; position: relative; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; }
        
        /* Headers */
        th { 
            background: var(--primary); color: white; 
            position: sticky; top: 0; z-index: 10; height: 50px; 
            font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;
            padding: 0 10px; border-right: 1px solid rgba(255,255,255,0.1); 
        }
        
        /* Cells */
        td { 
            border-right: 1px solid #eee; border-bottom: 1px solid #eee; 
            padding: 5px; text-align: center; font-size: 12px; 
            white-space: nowrap; height: 60px; vertical-align: middle; 
            min-width: 110px; /* Ensure space for time */
        }
        
        /* Sticky First Column */
        td:first-child, th:first-child { 
            position: sticky; left: 0; z-index: 11; 
            background: #fff; border-right: 2px solid #ddd; 
            font-weight: 700; text-align: left; padding-left: 20px; 
            min-width: 200px; color: var(--primary);
        }
        th:first-child { z-index: 12; background: var(--primary); color: white; }
        
        /* Hover Effects */
        tr:hover td { background-color: #f9f9f9; }
        tr:hover td:first-child { background-color: #f9f9f9; }
        td.cell-clickable { cursor: pointer; transition: 0.1s; }
        td.cell-clickable:hover { background-color: #e3f2fd !important; outline: 2px solid var(--primary); z-index: 5; }

        /* --- STATUS COLORS --- */
        .P { background: #e8f5e9; color: #155724; }
        .A { background: #ffebee; color: #721c24; font-weight: bold; font-size: 13px; }
        .L { background: #fff3cd; color: #856404; }
        .WO { background: #e3f2fd; color: #1565c0; font-weight: bold; }
        .HO { background: #f3e5f5; color: #6a1b9a; font-weight: bold; }
        .Future { background: #fff; color: #ccc; }

        /* Content inside cells */
        .time-box { display: flex; flex-direction: column; justify-content: center; gap: 2px; font-size: 10px; line-height: 1.3; }
        .time-row { font-family: monospace; font-size: 10px; }
        .late-badge { color: #d32f2f; font-weight: 800; font-size: 9px; display: block; margin-bottom: 2px; text-transform: uppercase; }
        .manual-dot { width: 6px; height: 6px; background: #333; border-radius: 50%; position: absolute; top: 4px; right: 4px; }

        /* --- MODAL --- */
        .modal { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 25px; border-radius: 8px; width: 380px; box-shadow: 0 15px 40px rgba(0,0,0,0.2); }
        .modal-header { font-size: 18px; font-weight: bold; margin-bottom: 20px; color: var(--primary); border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; margin-bottom: 5px; font-size: 12px; font-weight: bold; color: #555; }
        .input-group input, .input-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; background: #fcfcfc; }
        
        .modal-actions { margin-top: 25px; display: flex; gap: 10px; }
        .btn-modal { flex: 1; padding: 10px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; color: white; transition: 0.2s; }
        .btn-save { background: var(--primary); }
        .btn-reset { background: var(--danger); }
        .btn-cancel { background: #95a5a6; }

        /* --- PRINT MODE --- */
        @media print {
            @page { size: landscape; margin: 5mm; }
            body { background: white; }
            .sidebar, .topbar, .controls-card, .legend, .modal, #loading { display: none !important; }
            .main-content { overflow: visible; height: auto; }
            .content { padding: 0; margin: 0; height: auto; overflow: visible; }
            .table-container { box-shadow: none; border: 1px solid #000; overflow: visible; height: auto; }
            table { width: 100%; font-size: 10px; border-collapse: collapse; }
            th, td { border: 1px solid #000 !important; padding: 2px; height: auto; color: #000 !important; }
            th { background: #ddd !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .manual-dot { display: none; }
            /* Force colors */
            .P { background-color: #e8f5e9 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .A { background-color: #ffebee !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .WO { background-color: #e3f2fd !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }

        #loading { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.95); z-index: 10000; display: flex; flex-direction: column; justify-content: center; align-items: center; }
    </style>
</head>
<body>

    <div id="loading">
        <div style="font-size: 40px;">📅</div>
        <div style="margin-top:10px; font-weight:bold; color:#555;">Loading Report...</div>
    </div>

    <nav class="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
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
                <a href="reports.jsp" class="active"><span class="nav-icon">📅</span> Attendance</a>
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
            <button onclick="logout()" class="btn-logout">Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div class="page-title">Attendance & Management</div>
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
                <div class="legend-item"><span class="dot P"></span> Present</div>
                <div class="legend-item"><span class="dot L"></span> Late</div>
                <div class="legend-item"><span class="dot A"></span> Absent</div>
                <div class="legend-item"><span class="dot WO"></span> Week Off</div>
                <div class="legend-item"><span class="dot HO"></span> Holiday</div>
                <div class="legend-item" style="margin-left:auto; color:var(--primary); font-weight:bold;">* Click cell to edit</div>
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
            <div class="modal-header">Edit Attendance Record</div>
            
            <div class="input-group">
                <label>Employee Name</label>
                <input type="text" id="modalEmpName" disabled>
                <input type="hidden" id="modalEmpEmail">
            </div>

            <div class="input-group">
                <label>Selected Date</label>
                <input type="text" id="modalDateDisplay" disabled>
                <input type="hidden" id="modalDateValue">
            </div>

            <div class="input-group">
                <label>Set Status</label>
                <select id="modalStatus">
                    <option value="P">Present (P)</option>
                    <option value="A">Absent (A)</option>
                    <option value="WO">Week Off (WO)</option>
                    <option value="HO">Holiday (HO)</option>
                </select>
            </div>

            <div class="modal-actions">
                <button onclick="saveManual()" class="btn-modal btn-save">Save Override</button>
                <button onclick="resetManual()" class="btn-modal btn-reset">Reset to Auto</button>
                <button onclick="closeModal()" class="btn-modal btn-cancel">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        // 1. FIREBASE CONFIG
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

        // 2. VARIABLES
        let allUsers = [];
        let autoData = [];
        let manualData = {};
        const daysMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // 3. INITIALIZATION
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

        // 4. FETCH DATA
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
                
                // Users
                allUsers = [];
                usersSnap.forEach(doc => {
                    const d = doc.data();
                    if(d.role !== 'admin') allUsers.push({ 
                        email: d.email, name: d.fullName || d.email, shifts: d.shiftTimings || {} 
                    });
                });
                allUsers.sort((a,b) => a.name.localeCompare(b.name));

                // Auto Data
                autoData = [];
                autoSnap.forEach(doc => autoData.push(doc.data()));

                // Manual Data
                manualData = {};
                manualSnap.forEach(doc => manualData[doc.id] = doc.data().status);

                renderTable(m, y);
                document.getElementById("loading").style.display = "none";
            });
        }

        // 5. RENDER TABLE
        function renderTable(m, y) {
            const daysInM = new Date(y, m + 1, 0).getDate();
            const tHead = document.getElementById("tableHeader");
            const tBody = document.getElementById("tableBody");
            const today = new Date(); today.setHours(0,0,0,0);

            // Header
            let hHtml = "<th>Employee Name</th>";
            for(let i=1; i<=daysInM; i++) hHtml += "<th>" + i + "</th>";
            tHead.innerHTML = hHtml;

            // Body
            let bHtml = "";
            allUsers.forEach(user => {
                bHtml += "<tr><td>" + user.name + "</td>";
                
                for(let d=1; d<=daysInM; d++) {
                    const colDate = new Date(y, m, d);
                    colDate.setHours(0,0,0,0);
                    
                    const dateStr = y + "-" + String(m+1).padStart(2,'0') + "-" + String(d).padStart(2,'0');
                    const manualId = user.email + "_" + dateStr;
                    
                    // FIXED: String concatenation for onclick to prevent JSP/500 errors
                    const clickAct = "openEdit('" + user.email + "', '" + user.name.replace(/'/g, "\\'") + "', '" + dateStr + "')";

                    // 1. Manual Override
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

                    // 3. Auto Logic
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
                        
                        // Time Format
                        const timeOpts = {hour:'2-digit', minute:'2-digit', hour12:true};
                        const inStr = inT.toLocaleTimeString([], timeOpts);
                        const outStr = outT ? outT.toLocaleTimeString([], timeOpts) : "--:--";

                        // Late Check
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
                        bHtml += "<td class='cell-clickable A' onclick=\"" + clickAct + "\">Absent</td>";
                    }
                }
                bHtml += "</tr>";
            });
            tBody.innerHTML = bHtml;
        }

        // 6. MODAL FUNCTIONS
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
                email: email, dateString: dateStr, status: status,
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
    </script>
</body>
</html>