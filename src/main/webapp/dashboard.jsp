<%@ page import="java.sql.*" %>

<%@ page import="java.util.*" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>



<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta http-equiv="refresh" content="5"> <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Attendance Dashboard</title>

    

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    

    <style>

        .status-present { color: white; background-color: #28a745; font-weight: bold; }

        .status-absent { color: white; background-color: #dc3545; font-weight: bold; }

        .card-custom { margin-top: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }

    </style>

</head>

<body class="bg-light">



<div class="container">

    <div class="row justify-content-center">

        <div class="col-md-10">

            

            <div class="card card-custom">

                <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">

                    <h4 class="mb-0">🏢 Employee Attendance</h4>

                    <span class="badge bg-secondary">Live Feed</span>

                </div>

                <div class="card-body">

                    

                    <table class="table table-hover table-bordered text-center align-middle">

                        <thead class="table-dark">

                            <tr>

                                <th>ID</th>

                                <th>Employee Name</th>

                                <th>Role</th>

                                <th>Status</th>

                                <th>Last Activity</th>

                            </tr>

                        </thead>

                        <tbody>

                            <%

                                Connection conn = null;

                                PreparedStatement stmt = null;

                                ResultSet rs = null;



                                try {

                                    // 1. Connect to Database

                                    Class.forName("com.mysql.cj.jdbc.Driver");

                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/attendance_db", "webadmin", "password123");



                                    // 2. Query Users and their LAST scan time

                                    String query = "SELECT u.id, u.name, u.role, u.current_status, " +

                                                   "(SELECT MAX(scan_time) FROM attendance_log WHERE user_id = u.id) as last_seen " +

                                                   "FROM users u";

                                    

                                    stmt = conn.prepareStatement(query);

                                    rs = stmt.executeQuery();



                                    while (rs.next()) {

                                        String status = rs.getString("current_status");

                                        String badgeClass = "Present".equalsIgnoreCase(status) ? "status-present" : "status-absent";

                                        String lastSeen = rs.getString("last_seen");

                                        if (lastSeen == null) lastSeen = "--";

                            %>

                            <tr>

                                <td><%= rs.getInt("id") %></td>

                                <td class="fw-bold"><%= rs.getString("name") %></td>

                                <td><%= rs.getString("role") %></td>

                                <td><span class="badge rounded-pill <%= badgeClass %> px-3 py-2"><%= status %></span></td>

                                <td class="text-muted"><%= lastSeen %></td>

                            </tr>

                            <%

                                    }

                                } catch (Exception e) {

                                    out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");

                                } finally {

                                    if(rs != null) rs.close();

                                    if(stmt != null) stmt.close();

                                    if(conn != null) conn.close();

                                }

                            %>

                        </tbody>

                    </table>



                </div>

            </div>

            

            <div class="text-center mt-3 text-muted">

                <small>System updates automatically every 5 seconds.</small>

            </div>



        </div>

    </div>

</div>



</body>

</html>