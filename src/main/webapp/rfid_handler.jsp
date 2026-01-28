<%@ page import="java.sql.*" %>

<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>

<%

    // --- DATABASE CONFIG (Matches the user we just created) ---

    String dbURL = "jdbc:mysql://localhost:3306/attendance_db";

    String dbUser = "webadmin";

    String dbPass = "password123";



    String uid = request.getParameter("uid");

    String jsonResponse = "";



    Connection conn = null;

    try {

        // Load Driver

        Class.forName("com.mysql.cj.jdbc.Driver");

        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);



        // 1. Create Log Table if it doesn't exist (Keeps history)

        String createLogTable = "CREATE TABLE IF NOT EXISTS attendance_log (" +

                                "log_id INT AUTO_INCREMENT PRIMARY KEY, " +

                                "user_id INT, " +

                                "user_name VARCHAR(100), " +

                                "action_type VARCHAR(10), " + // IN or OUT

                                "scan_time DATETIME DEFAULT CURRENT_TIMESTAMP)";

        conn.createStatement().executeUpdate(createLogTable);



        if (uid != null && !uid.isEmpty()) {

            // 2. CHECK USER: We look for 'rfid_uid' inside 'users' table

            String sql = "SELECT id, name, current_status FROM users WHERE rfid_uid = ?";

            PreparedStatement stmt = conn.prepareStatement(sql);

            stmt.setString(1, uid);

            ResultSet rs = stmt.executeQuery();



            if (rs.next()) {

                // User Found

                int userId = rs.getInt("id");

                String name = rs.getString("name"); // "Srinivas R"

                String currentStatus = rs.getString("current_status"); // "Absent"



                // 3. LOGIC: Swap Status

                // If Absent -> Set to Present (IN)

                // If Present -> Set to Absent (OUT)

                String newStatus = "Present";

                String action = "IN";

                

                if ("Present".equalsIgnoreCase(currentStatus)) {

                    newStatus = "Absent";

                    action = "OUT";

                }



                // 4. UPDATE 'users' table

                PreparedStatement updateStmt = conn.prepareStatement("UPDATE users SET current_status = ? WHERE id = ?");

                updateStmt.setString(1, newStatus);

                updateStmt.setInt(2, userId);

                updateStmt.executeUpdate();



                // 5. INSERT into 'attendance_log' (History)

                PreparedStatement logStmt = conn.prepareStatement("INSERT INTO attendance_log (user_id, user_name, action_type) VALUES (?, ?, ?)");

                logStmt.setInt(1, userId);

                logStmt.setString(2, name);

                logStmt.setString(3, action);

                logStmt.executeUpdate();



                // 6. SUCCESS RESPONSE

                jsonResponse = String.format("{\"status\": \"success\", \"name\": \"%s\", \"action\": \"%s\"}", name, action);

                

            } else {

                jsonResponse = "{\"status\": \"error\", \"message\": \"Card Not Registered\"}";

            }

        } else {

            jsonResponse = "{\"status\": \"error\", \"message\": \"No UID Received\"}";

        }

    } catch (Exception e) {

        String safeError = e.getMessage().replace("\"", "'");

        jsonResponse = String.format("{\"status\": \"error\", \"message\": \"%s\"}", safeError);

    } finally {

        if(conn != null) try { conn.close(); } catch(SQLException e) {}

    }

    

    out.print(jsonResponse);

%>