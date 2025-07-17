/******************************************
 * My Login
 *
 * Bootstrap 4 Login Page
 *
 * @author         Muhamad Nauval Azhar
 * @uri            https://nauval.in
 * @copyright      Copyright (c) 2018 Muhamad Nauval Azhar
 * @license        My Login is licensed under the MIT license.
 * @github         https://github.com/nauvalazhar/my-login
 * @version        1.2.0
 *
 * Help me to keep this project alive
 * https://www.buymeacoffee.com/mhdnauvalazhar
 *
 ******************************************/

'use strict';

$(function() {

    // author badge :)
    var author = '<div style="position: fixed;bottom: 0;right: 20px;background-color: #fff;box-shadow: 0 4px 8px rgba(0,0,0,.05);border-radius: 3px 3px 0 0;font-size: 12px;padding: 5px 10px;">By <a href="https://twitter.com/mhdnauvalazhar">@mhdnauvalazhar</a> &nbsp;&bull;&nbsp; <a href="https://www.buymeacoffee.com/mhdnauvalazhar">Buy me a Coffee</a></div>';
    $("body").append(author);

    $("input[type='password'][data-eye]").each(function(i) {
        var $this = $(this),
            id = 'eye-password-' + i,
            el = $('#' + id);

        $this.wrap($("<div/>", {
            style: 'position:relative',
            id: id
        }));

        $this.css({
            paddingRight: 60
        });
        $this.after($("<div/>", {
            html: 'Show',
            class: 'btn btn-primary btn-sm',
            id: 'passeye-toggle-'+i,
        }).css({
                position: 'absolute',
                right: 10,
                top: ($this.outerHeight() / 2) - 12,
                padding: '2px 7px',
                fontSize: 12,
                cursor: 'pointer',
        }));

        $this.after($("<input/>", {
            type: 'hidden',
            id: 'passeye-' + i
        }));

        var invalid_feedback = $this.parent().parent().find('.invalid-feedback');

        if(invalid_feedback.length) {
            $this.after(invalid_feedback.clone());
        }

        $this.on("keyup paste", function() {
            $("#passeye-"+i).val($(this).val());
        });
        $("#passeye-toggle-"+i).on("click", function() {
            if($this.hasClass("show")) {
                $this.attr('type', 'password');
                $this.removeClass("show");
                $(this).removeClass("btn-outline-primary");
            }else{
                $this.attr('type', 'text');
                $this.val($("#passeye-"+i).val());
                $this.addClass("show");
                $(this).addClass("btn-outline-primary");
            }
        });
    });

    // 기존 폼 유효성 검사 로직
    $(".my-login-validation").submit(function(event) { // event 객체를 인자로 받음
        var form = $(this);

        // HTML5 기본 유효성 검사
        if (form[0].checkValidity() === false) {
          event.preventDefault(); // 기본 폼 제출 방지
          event.stopPropagation(); // 이벤트 전파 중단
        } else {
            // 폼 유효성 검사를 통과했을 때만 서버로 데이터 전송
            event.preventDefault(); // 폼의 기본 제출 동작 방지 (새 페이지 로드 방지)

            // 폼 데이터 수집 (로그인 폼 기준: 이메일과 비밀번호)
            // register.html에서는 name, email, password를 수집해야 함
            var email = form.find('#email').val();
            var password = form.find('#password').val();

            // 만약 register.html이라면 다음과 같이 데이터 수집 (예시)
            // var name = form.find('#name').val();
            // var email = form.find('#email').val();
            // var password = form.find('#password').val();

            // 서버로 보낼 데이터 객체
            var formData = {
                email: email,
                password: password
                // register.html이라면: name: name, email: email, password: password
            };

            // 서버 API 엔드포인트 URL (실제 백엔드 서버 주소로 변경 필요)
            // 이 예시는 로그인 엔드포인트입니다. 회원가입이라면 다른 URL을 사용해야 합니다.
            var apiUrl = '/api/login'; // 예시: 로그인 API 엔드포인트
            // var apiUrl = '/api/register'; // 예시: 회원가입 API 엔드포인트

            // AJAX를 사용하여 서버에 데이터 전송
            $.ajax({
                url: apiUrl,
                type: 'POST', // POST 방식으로 데이터 전송
                contentType: 'application/json', // JSON 형태로 데이터 전송을 명시
                data: JSON.stringify(formData), // JavaScript 객체를 JSON 문자열로 변환하여 전송
                beforeSend: function() {
                    // 선택 사항: 로딩 스피너 표시 등
                    console.log('서버로 요청 전송 중...');
                    // 예: $('button[type="submit"]').prop('disabled', true).text('로그인 중...');
                },
                success: function(response) {
                    // 서버로부터 성공적인 응답을 받았을 때
                    console.log('서버 응답:', response);

                    if (response.success) { // 서버 응답에 success 필드가 있다고 가정
                        alert('로그인 성공!');
                        // 로그인 성공 시 메인 페이지로 이동 또는 대시보드 페이지로 리다이렉트
                        window.location.href = '/index.html'; // 또는 /dashboard.html 등
                    } else {
                        // 로그인 실패 (서버에서 'success: false' 또는 에러 메시지 반환 시)
                        alert('로그인 실패: ' + (response.message || '아이디 또는 비밀번호가 올바르지 않습니다.'));
                        // 예: 에러 메시지를 폼 하단에 표시
                    }
                },
                error: function(xhr, status, error) {
                    // 서버 요청 실패 (네트워크 문제, 서버 에러 등)
                    console.error('AJAX 오류:', status, error, xhr);
                    alert('로그인 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
                    // 예: 에러 메시지를 폼 하단에 표시
                },
                complete: function() {
                    // 선택 사항: 로딩 스피너 숨김 등
                    console.log('요청 완료.');
                    // 예: $('button[type="submit"]').prop('disabled', false).text('로그인');
                }
            });
        }
        form.addClass('was-validated'); // 유효성 검사 결과를 시각적으로 표시
    });
});