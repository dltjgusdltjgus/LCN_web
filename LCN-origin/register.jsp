<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="author" content="Kodinger">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Register Page</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <link rel="stylesheet" type="text/css" href="css/my-login.css">
</head>
<body class="my-login-page">
    <section class="h-100">
        <div class="container h-100">
            <div class="row justify-content-md-center h-100">
                <div class="card-wrapper">
                    <div class="brand">
                        <img src="img/logo.png" alt="bootstrap 4 login page">
                    </div>
                    <div class="card fat">
                        <div class="card-body">
                            <h4 class="card-title">Register</h4>
                            <%
                                String message = "";
                                // 폼이 POST 방식으로 제출되었는지 확인
                                if (request.getMethod().equalsIgnoreCase("POST")) {
                                    String name = request.getParameter("name");
                                    String userID = request.getParameter("userID"); // HTML 폼의 name="userID"
                                    String email = request.getParameter("email");
                                    String password = request.getParameter("password");
                                    String confirmPassword = request.getParameter("confirmPassword");
                                    String mobile = request.getParameter("mobile");
                                    String birthYearStr = request.getParameter("birthYear");
                                    int birthYear = 0;

                                    // 필수 필드 유효성 검사
                                    if (name == null || name.isEmpty() ||
                                        userID == null || userID.isEmpty() ||
                                        email == null || email.isEmpty() ||
                                        password == null || password.isEmpty() ||
                                        confirmPassword == null || confirmPassword.isEmpty() ||
                                        mobile == null || mobile.isEmpty() ||
                                        birthYearStr == null || birthYearStr.isEmpty()) {
                                        message = "<div class='alert alert-warning'>모든 필드를 채워주세요.</div>";
                                    } else if (!password.equals(confirmPassword)) {
                                        message = "<div class='alert alert-danger'>비밀번호와 비밀번호 확인이 일치하지 않습니다.</div>";
                                    } else {
                                        try {
                                            birthYear = Integer.parseInt(birthYearStr);
                                        } catch (NumberFormatException e) {
                                            message = "<div class='alert alert-danger'>출생 연도가 올바른 숫자가 아닙니다.</div>";
                                        }

                                        if (message.isEmpty()) { // 모든 유효성 검사 통과 시 DB 저장 시도
                                            Connection conn = null;
                                            PreparedStatement pstmt = null;

                                            String dbUrl = "jdbc:mariadb://lcn-kr-db.c9g48swe6aab.ap-northeast-2.rds.amazonaws.com:3306/LCN";
                                            String dbUser = "admin";
                                            String dbPass = "powerlcn";

                                            try {
                                                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                                                // ★★★ SQL 쿼리 수정: 'users' 테이블에 새로운 컬럼들을 추가해야 합니다! ★★★
                                                // 테이블 구조: id, user_id, PW, name, email, mobile, birth_year
                                                // user_id는 HTML 폼의 name="userID"에서 가져옵니다.
                                                // email은 HTML 폼의 name="email"에서 가져옵니다.
                                                // PW는 HTML 폼의 name="password"에서 가져옵니다.
                                                // name은 HTML 폼의 name="name"에서 가져옵니다.
                                                // mobile은 HTML 폼의 name="mobile"에서 가져옵니다.
                                                // birthYear는 HTML 폼의 name="birthYear"에서 가져옵니다.

                                                // user_id (UNIQUE) 중복 확인
                                                String checkSql = "SELECT COUNT(*) FROM users WHERE user_id = ?";
                                                pstmt = conn.prepareStatement(checkSql);
                                                pstmt.setString(1, userID);
                                                ResultSet rs = pstmt.executeQuery();
                                                if (rs.next() && rs.getInt(1) > 0) {
                                                    message = "<div class='alert alert-danger'>이미 존재하는 사용자 ID입니다. 다른 ID를 사용해주세요.</div>";
                                                } else {
                                                    rs.close();
                                                    pstmt.close();

                                                    // 사용자 등록 쿼리
                                                    // 테이블에 name, email, mobile, birth_year 컬럼이 추가되어야 합니다.
                                                    String insertSql = "INSERT INTO users (user_id, PW, name, email, mobile, birth_year) VALUES (?, ?, ?, ?, ?, ?)";
                                                    pstmt = conn.prepareStatement(insertSql);
                                                    pstmt.setString(1, userID);
                                                    pstmt.setString(2, password); // ★★★ 실제 환경에서는 비밀번호를 해싱하여 저장해야 합니다! ★★★
                                                    pstmt.setString(3, name);
                                                    pstmt.setString(4, email);
                                                    pstmt.setString(5, mobile);
                                                    pstmt.setInt(6, birthYear);

                                                    int rowsAffected = pstmt.executeUpdate();

                                                    if (rowsAffected > 0) {
                                                        message = "<div class='alert alert-success'>회원가입 성공! 이제 로그인할 수 있습니다.</div>";
                                                        // 회원가입 성공 시 로그인 페이지로 리다이렉션
                                                        response.sendRedirect("login.jsp");
                                                        return; // 리다이렉션 후 추가 코드 실행 방지
                                                    } else {
                                                        message = "<div class='alert alert-danger'>회원가입 실패: 알 수 없는 오류가 발생했습니다.</div>";
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                // SQLSTATE 23000은 주로 UNIQUE 제약 조건 위반 (예: user_id 중복)
                                                if (e.getSQLState().startsWith("23")) {
                                                    message = "<div class='alert alert-danger'>회원가입 실패: 이미 존재하는 사용자 ID 또는 이메일입니다.</div>";
                                                } else {
                                                    message = "<div class='alert alert-danger'>데이터베이스 오류: " + e.getMessage() + "</div>";
                                                }
                                                e.printStackTrace();
                                            } finally {
                                                try {
                                                    if (pstmt != null) pstmt.close();
                                                    if (conn != null) conn.close();
                                                } catch (SQLException e) {
                                                    e.printStackTrace();
                                                }
                                            }
                                        }
                                    }
                                }
                            %>
                            <%= message %> <%-- 메시지 출력 --%>

                            <form method="POST" action="register.jsp" class="my-login-validation" novalidate="">
                                <div class="form-group">
                                    <label for="name">Name</label>
                                    <input id="name" type="text" class="form-control" name="name" value="<%= (request.getParameter("name") != null ? request.getParameter("name") : "") %>" required autofocus>
                                    <div class="invalid-feedback">
                                        What's your name?
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="userID">ID</label> <%-- label for="ID"는 HTML id="ID"와 매칭 --%>
                                    <input id="userID" type="text" class="form-control" name="userID" value="<%= (request.getParameter("userID") != null ? request.getParameter("userID") : "") %>" required>
                                    <div class="invalid-feedback">
                                        Please enter your ID.
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="email">E-Mail Address</label>
                                    <input id="email" type="email" class="form-control" name="email" value="<%= (request.getParameter("email") != null ? request.getParameter("email") : "") %>" required>
                                    <div class="invalid-feedback">
                                        Your email is invalid
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="password">Password</label>
                                    <input id="password" type="password" class="form-control" name="password" required data-eye>
                                    <div class="invalid-feedback">
                                        Password is required
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="confirmPassword">Confirm Password</label>
                                    <input id="confirmPassword" type="password" class="form-control" name="confirmPassword" required data-eye>
                                    <div class="invalid-feedback">
                                        Please confirm your password
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="mobile">Mobile Number</label>
                                    <input id="mobile" type="text" class="form-control" name="mobile" value="<%= (request.getParameter("mobile") != null ? request.getParameter("mobile") : "") %>" required>
                                    <div class="invalid-feedback">
                                        Mobile number is required
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="birthYear">Birth Year</label>
                                    <input id="birthYear" type="number" class="form-control" name="birthYear" value="<%= (request.getParameter("birthYear") != null ? request.getParameter("birthYear") : "") %>" required>
                                    <div class="invalid-feedback">
                                        Birth year is required
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="custom-checkbox custom-control">
                                        <input type="checkbox" name="agree" id="agree" class="custom-control-input" required="">
                                        <label for="agree" class="custom-control-label">I agree to the <a href="#">Terms and Conditions</a></label>
                                        <div class="invalid-feedback">
                                            You must agree with our Terms and Conditions
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group m-0">
                                    <button type="submit" class="btn btn-primary btn-block">
                                        Register
                                    </button>
                                </div>
                                <div class="mt-4 text-center">
                                    Already have an account? <a href="login.jsp">Login</a> <%-- login.html 대신 login.jsp로 변경 --%>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="footer">
                        Copyright &copy; 2017 &mdash; Your Company
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <script src="js/my-login.js"></script>
</body>
</html>
