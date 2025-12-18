<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Settings</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; display: flex; background: #f4f6f9; margin: 0; }
        
        /* Sidebar (Same as Dashboard for consistency) */
        .sidebar { width: 260px; background: #343a40; color: white; height: 100vh; display:flex; flex-direction:column; }
        .brand { padding: 25px; font-weight:bold; background:#212529; text-align:center; font-size:20px; border-bottom:1px solid #4b545c;}
        .sidebar a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; }
        .sidebar a:hover { background: #495057; color: white; }

        /* Main Area */
        .main { flex: 1; padding: 40px; }
        .card { background: white; padding: 30px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); max-width: 600px; }
        
        h2 { margin-top: 0; color: #333; }
        h3 { border-bottom: 1px solid #eee; padding-bottom: 10px; font-size: 16px; color: #555; }
        
        input { width: 100%; padding: 12px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        button { padding: 12px 20px; border: none; border-radius: 5px; cursor: pointer; color: white; font-weight: bold; }
        .btn-green { background: #28a745; }
        .btn-blue { background: #007bff; }
    </style>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div class="sidebar">
        <div class="brand">🛡️ Admin Panel</div>
        <a href="admin_dashboard.jsp">📊 Attendance Monitor</a>
        <a href="admin_tasks.jsp">📝 Task Assignment</a>
        <a href="admin_expenses.jsp">💸 Employee Expenses</a>
        <a href="admin_accounts.jsp">🏦 Company Accounts</a>
        <a href="#" style="background:#495057; color:white; border-left:4px solid #28a745;">⚙️ Settings</a>
    </div>

    <div class="main">
        <h2>⚙️ Admin Settings</h2>

        <div class="card">
            <h3>🖼 Change Profile Picture</h3>
            <input type="file" id="fileInput">
            <button class="btn-blue" onclick="alert('Profile Picture Upload: This requires Firebase Storage enabled. For now, this is a UI placeholder.')">Upload New Picture</button>
        </div>

        <div class="card">
            <h3>🔒 Reset Password</h3>
            <p style="color:#666; font-size:14px;">Enter a new password to update your login credentials.</p>
            <input type="password" id="newPass" placeholder="New Password">
            <button class="btn-green" onclick="updatePass()">Update Password</button>
        </div>
    </div>

    <script>
        // --- PASTE FIREBASE CONFIG HERE ---
         const firebaseConfig = {
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b",
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();

        function updatePass() {
            const pass = document.getElementById("newPass").value;
            const user = auth.currentUser;
            
            if(user && pass) {
                if(pass.length < 6) { alert("Password must be 6+ chars"); return; }
                
                user.updatePassword(pass).then(() => {
                    alert("✅ Password Updated Successfully! Please login again.");
                    auth.signOut().then(() => window.location.href="login.jsp");
                }).catch(e => alert("Error: " + e.message));
            } else {
                alert("Please wait for page to load or login again.");
            }
        }
    </script>
</body>
</html>