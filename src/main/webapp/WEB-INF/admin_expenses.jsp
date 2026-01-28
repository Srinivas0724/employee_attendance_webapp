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
    <title>Expense Approvals - Synod Bioscience</title>
    
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

        .content { padding: 30px 40px; max-width: 1600px; margin: 0 auto; width: 100%; }

        /* --- 4. EXPENSE CARD --- */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; display: flex; flex-direction: column; }
        .card-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        .card-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--primary-navy); }

        /* Refresh Button */
        .btn-refresh { 
            padding: 10px 20px; border: none; border-radius: 8px; 
            background: white; border: 1px solid #e0e0e0; 
            color: var(--text-dark); font-weight: 600; cursor: pointer; 
            transition: 0.2s; display: flex; align-items: center; gap: 8px; font-size: 13px;
        }
        .btn-refresh:hover { background: #f9f9f9; border-color: var(--primary-navy); color: var(--primary-navy); }

        /* Table Styles */
        .table-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid #f0f0f0; }
        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th { background: #f8f9fa; padding: 15px; text-align: left; font-size: 12px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #f9f9f9; font-size: 14px; color: var(--text-dark); vertical-align: middle; }
        tr:hover td { background: #fcfcfc; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; letter-spacing: 0.5px; }
        .bg-Pending { background: #fff3cd; color: #f39c12; }
        .bg-Approved { background: #e3f2fd; color: #3498db; }
        .bg-Paid { background: #e8f5e9; color: #27ae60; }
        .bg-Rejected { background: #ffebee; color: #c0392b; }

        /* Actions */
        .btn-action { border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-size: 12px; color: white; margin-right: 5px; font-weight: 700; transition: 0.2s; display: inline-flex; align-items: center; gap: 5px; }
        .btn-action:hover { transform: translateY(-1px); opacity: 0.9; }
        
        .btn-approve { background: #3498db; box-shadow: 0 2px 5px rgba(52, 152, 219, 0.3); }
        .btn-pay { background: #27ae60; box-shadow: 0 2px 5px rgba(39, 174, 96, 0.3); }
        .btn-reject { background: #e74c3c; box-shadow: 0 2px 5px rgba(231, 76, 60, 0.3); }
        
        .btn-view { 
            background: white; border: 1px solid #e0e0e0; padding: 6px 12px; border-radius: 6px; 
            color: var(--text-dark); font-size: 12px; font-weight: 600; text-decoration: none; 
            display: inline-flex; align-items: center; gap: 5px; transition: 0.2s;
        }
        .btn-view:hover { background: #f9f9f9; border-color: var(--primary-navy); color: var(--primary-navy); }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: var(--primary-navy); flex-direction: column; font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }

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
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">💸</div>
        <div style="margin-top:15px;">Loading Expenses...</div>
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
            <li class="nav-item"><a href="list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp" class="active"><span class="nav-icon">💸</span> Expenses</a></li>
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
                    <div>
                        <h3 class="card-title">Pending & Recent Claims</h3>
                        <p style="font-size:13px; color:#7f8c8d; margin:5px 0 0 0;">Review, approve, and reimburse employee expenses.</p>
                    </div>
                    <button onclick="loadExpenses()" class="btn-refresh">🔄 Refresh List</button>
                </div>

                <div class="table-wrap">
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
                            <tr><td colspan="8" style="text-align:center; padding:30px; color:#999;">Loading records...</td></tr>
                        </tbody>
                    </table>
                </div>
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