package dao;

import model.User;
import util.DBConnection;
import java.sql.*;

public class UserDAO {
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getEmail());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
public boolean isUsernameTaken(String username) {
    boolean isTaken = false;
    try {
        Connection conn = DBConnection.getConnection(); 
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            isTaken = rs.getInt(1) > 0;
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return isTaken;
}

public boolean isEmailTaken(String email) {
    boolean isTaken = false;
    try {
        Connection conn = DBConnection.getConnection(); 
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            isTaken = rs.getInt(1) > 0;
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return isTaken;
}}

