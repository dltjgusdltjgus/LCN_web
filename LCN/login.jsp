<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<meta name="author" content="Kodinger">
	<title>My Login Page - Debug</title> <%-- 디버깅 중임을 명시 --%>
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" xintegrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
	<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/my-login.css">
</head>

<body class="my-login-page">
	<section class="h-100">
		<div class="container h-100">
			<div class="row justify-content-md-center h-100">
				<div class="card-wrapper">
					<div class="brand">
						<%-- 로고 이미지를 클릭하면 메인 페이지(index.jsp)로 이동하도록 수정 --%>
						<a href="<%= request.getContextPath() %>/index.jsp">
							<img src="<%= request.getContextPath() %>/img/logo.png" alt="logo">
						</a>
					</div>
					<div class="card fat">
						<div class="card-body">
							<h4 class="card-title">Login Debug</h4>
							<%
								String method = request.getMethod();
								String email = request.getParameter("email"); // HTML 폼의 'email' 필드
								String password = request.getParameter("password"); // HTML 폼의 'password' 필드
								String message = "";


								// 폼이 POST 방식으로 제출되었고 (email 파라미터가 존재하고 비어있지 않다면)
								if (request.getMethod().equalsIgnoreCase("POST") && email != null && !email.isEmpty() && password != null && !password.isEmpty()) {
									Connection conn = null;
									PreparedStatement pstmt = null;
									ResultSet rs = null;

									// MariaDB 연결 정보 (제공된 RDS 엔드포인트와 사용자 정보를 사용)
									String dbUrl = "jdbc:mariadb://lcn-kr-db.c9g48swe6aab.ap-northeast-2.rds.amazonaws.com:3306/LCN";
									String dbUser = "admin"; // 제공된 ID
									String dbPass = "powerlcn"; // 제공된 PW

									try {
										// 데이터베이스 연결
										conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

										// SQL 쿼리 준비 (보안을 위해 PreparedStatement 사용)
										// users 테이블 스키마에 맞춰 'email'과 'password' 컬럼을 사용합니다.
										String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
										pstmt = conn.prepareStatement(sql);
										pstmt.setString(1, email);
										pstmt.setString(2, password); // ★★★ 실제 환경에서는 비밀번호를 해싱하여 비교해야 합니다! ★★★

										// 쿼리 실행
										rs = pstmt.executeQuery();

										if (rs.next()) {
											message = "<div class='alert alert-success'>로그인 성공! 환영합니다, " + email + "!</div>";
											// 로그인 성공 시 메인 페이지로 리다이렉션
											response.sendRedirect("index.jsp");
											return; // 리다이렉션 후 추가 코드 실행 방지
										} else {
											message = "<div class='alert alert-danger'>로그인 실패: 이메일 또는 비밀번호가 올바르지 않습니다.</div>";
										}

									} catch (SQLException e) {
										message = "<div class='alert alert-danger'>데이터베이스 연결 또는 쿼리 오류: " + e.getMessage() + "</div>";
										e.printStackTrace(); // 개발 중에는 스택 트레이스를 확인하는 것이 유용합니다.
									} finally {
										// 자원 해제
										try {
											if (rs != null) rs.close();
											if (pstmt != null) pstmt.close();
											if (conn != null) conn.close();
										} catch (SQLException e) {
											e.printStackTrace();
										}
									}
								} else if (request.getMethod().equalsIgnoreCase("POST")) {
									// 폼이 제출되었으나 필수 필드가 비어있는 경우
									message = "<div class='alert alert-warning'>이메일과 비밀번호를 모두 입력해주세요.</div>";
								}
							%>
							<%= message %> <%-- 메시지 출력 --%>

							<form method="POST" action="<%= request.getContextPath() %>/login" class="my-login-validation" novalidate=""> <%-- 폼 제출 액션을 /login으로 설정 --%>
								<div class="form-group">
									<label for="email">E-Mail Address</label>
									<input id="email" type="email" class="form-control" name="email" value="<%= (email != null ? email : "") %>" required autofocus>
									<div class="invalid-feedback">
										Email is invalid
									</div>
								</div>

								<div class="form-group">
									<label for="password">Password
										<a href="forgot.html" class="float-right">
											Forgot Password?
										</a>
									</label>
									<input id="password" type="password" class="form-control" name="password" required data-eye>
								    <div class="invalid-feedback">
								    	Password is required
							    	</div>
								</div>

								<div class="form-group">
									<div class="custom-checkbox custom-control">
										<input type="checkbox" name="remember" id="remember" class="custom-control-input">
										<label for="remember" class="custom-control-label">Remember Me</label>
									</div>
								</div>

								<div class="form-group m-0">
									<button type="submit" class="btn btn-primary btn-block">
										Login
									</button>
								</div>
								<div class="mt-4 text-center">
									Don't have an account? <a href="<%= request.getContextPath() %>/register">Create One</a>
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

	<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" xintegrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" xintegrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" xintegrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	<!-- <script src="<%= request.getContextPath() %>/js/my-login.js"></script> -->
</body>
</html>

