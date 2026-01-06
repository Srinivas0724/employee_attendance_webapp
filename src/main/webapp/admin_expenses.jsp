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
    <title>Expense Approvals - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS (Admin Theme) --- */
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

        /* --- 4. PAGE SPECIFIC STYLES --- */
        .content { padding: 30px; max-width: 1400px; margin: 0 auto; width: 100%; }

        /* Card & Table */
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 4px solid var(--primary-navy); }
        
        .card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 2px solid #f4f6f9; padding-bottom: 15px; }
        .card-title { margin: 0; color: var(--primary-navy); font-size: 18px; font-weight: bold; }

        /* Refresh Button */
        .btn-refresh { 
            padding: 10px 20px; 
            background: var(--primary-navy); 
            color: white; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 14px; 
            font-weight: bold; 
            display: flex; align-items: center; gap: 8px;
            transition: 0.2s;
        }
        .btn-refresh:hover { background: #132c52; transform: translateY(-1px); }

        /* Table Styles */
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8f9fa; color: #666; padding: 15px 12px; text-align: left; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; font-weight: 700; }
        td { padding: 15px 12px; border-bottom: 1px solid #f1f1f1; color: #444; font-size: 14px; vertical-align: middle; }
        tr:hover { background: #fafafa; }

        /* Status Badges */
        .badge { padding: 6px 12px; border-radius: 20px; color: white; font-size: 11px; font-weight: bold; display: inline-block; letter-spacing: 0.5px; }
        .bg-Pending { background: #f39c12; color: white; }
        .bg-Approved { background: #3498db; }
        .bg-Paid { background: var(--primary-green); }
        .bg-Rejected { background: #e74c3c; }

        /* Action Buttons */
        .btn-action { border: none; padding: 8px 12px; border-radius: 5px; cursor: pointer; font-size: 12px; color: white; margin-right: 5px; font-weight: 600; transition: opacity 0.2s; }
        .btn-action:hover { opacity: 0.8; }
        
        .btn-approve { background: #3498db; }
        .btn-pay { background: var(--primary-green); }
        .btn-reject { background: #e74c3c; }
        
        .btn-view { 
            background: #ecf0f1; text-decoration: none; padding: 6px 12px; border-radius: 4px; 
            color: #555; font-size: 12px; display: inline-block; border: 1px solid #ddd; font-weight: 600;
        }
        .btn-view:hover { background: #e0e0e0; color: #333; }

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
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">💸</div>
        <div>Loading Claims...</div>
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
                <a href="admin_attendance.jsp"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp" class="active"><span class="nav-icon">💸</span> Expenses</a>
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
                <div class="page-title">Expense Management</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            <div class="card">
                <div class="card-header-row">
                    <h3 class="card-title">Pending & Recent Claims</h3>
                    <button onclick="loadExpenses()" class="btn-refresh">🔄 Refresh Data</button>
                </div>

                <table id="claimsTable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Employee</th>
                            <th>Type</th>
                            <th>Details</th>
                            <th>Amount</th>
                            <th>Receipt</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <tr><td colspan="8" style="text-align:center; padding:20px;">Loading records...</td></tr>
                    </tbody>
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

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("adminEmail").innerText = user.email;
                loadExpenses();
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. LOAD DATA ---
        function loadExpenses() {
            const tbody = document.getElementById("tableBody");
            
            db.collection("expenses")
              .orderBy("date", "desc")
              .get()
              .then(snap => {
                  document.getElementById("loadingOverlay").style.display = "none";
                  
                  if(snap.empty) {
                      tbody.innerHTML = "<tr><td colspan='8' style='text-align:center; padding:20px;'>No claims found.</td></tr>";
                      return;
                  }

                  let rows = "";
                  snap.forEach(doc => {
                      const d = doc.data();
                      const id = doc.id;
                      const date = d.date ? new Date(d.date.seconds * 1000).toLocaleDateString() : "-";
                      
                      // 1. NORMALIZE STATUS (Fix Case Sensitivity)
                      let rawStatus = d.status || "Pending";
                      // Convert 'pending' -> 'Pending', 'APPROVED' -> 'Approved'
                      let status = rawStatus.charAt(0).toUpperCase() + rawStatus.slice(1).toLowerCase();

                      // Receipt Logic
                      let receiptHtml = "<span style='color:#ccc; font-size:12px;'>No File</span>";
                      if(d.receiptUrl) {
                          receiptHtml = "<a href='" + d.receiptUrl + "' target='_blank' class='btn-view'>📎 View</a>";
                      }

                      // Buttons Logic (Enhanced)
                      let actionsHtml = "";
                      
                      // Case 1: Pending -> Can Approve OR Reject
                      if(status === 'Pending') {
                          actionsHtml += "<button class='btn-action btn-approve' onclick='updateStatus(\"" + id + "\", \"Approved\")'>✅ Approve</button>";
                          actionsHtml += "<button class='btn-action btn-reject' onclick='updateStatus(\"" + id + "\", \"Rejected\")'>❌ Reject</button>";
                      } 
                      // Case 2: Approved -> Can Mark Paid OR Reject (if mistake)
                      else if (status === 'Approved') {
                          actionsHtml += "<button class='btn-action btn-pay' onclick='updateStatus(\"" + id + "\", \"Paid\")'>💸 Mark Paid</button>";
                          actionsHtml += "<button class='btn-action btn-reject' onclick='updateStatus(\"" + id + "\", \"Rejected\")'>❌ Reject</button>";
                      } 
                      // Case 3: Paid/Rejected -> No actions
                      else if (status === 'Paid') {
                          actionsHtml = "<span style='color:#27ae60; font-weight:bold;'>Paid & Closed</span>";
                      }
                      else {
                          actionsHtml = "<span style='color:#999;'>Closed</span>";
                      }

                      // String Concatenation for Safety
                      rows += "<tr>";
                      rows += "<td>" + date + "</td>";
                      rows += "<td>" + d.email + "</td>";
                      rows += "<td>" + d.type + "</td>";
                      rows += "<td>" + d.description + "</td>";
                      rows += "<td><b>₹" + d.amount + "</b></td>";
                      rows += "<td>" + receiptHtml + "</td>";
                      rows += "<td><span class='badge bg-" + status + "'>" + status + "</span></td>";
                      rows += "<td>" + actionsHtml + "</td>";
                      rows += "</tr>";
                  });
                  tbody.innerHTML = rows;
              });
        }

        // --- 4. ACTIONS ---
        function updateStatus(docId, status) {
            if(!confirm("Are you sure you want to mark this claim as " + status + "?")) return;
            
            db.collection("expenses").doc(docId).update({
                status: status
            }).then(() => {
                alert("✅ Status Updated to " + status);
                loadExpenses();
            }).catch(e => alert("Error: " + e.message));
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