import os
import time
import sys

# --- 환경 변수 읽어오기 ---
db_endpoint = os.environ.get("DB_ENDPOINT")
db_username = os.environ.get("DB_USERNAME")
db_password = os.environ.get("DB_PASSWORD") # 보안상 출력에 주의

# 필수 환경 변수가 누락되었는지 확인
if not all([db_endpoint, db_username, db_password]):
    print("오류: 데이터베이스 연결에 필요한 환경 변수(DB_ENDPOINT, DB_USERNAME, DB_PASSWORD) 중 일부가 누락되었습니다.")
    sys.exit(1) # 스크립트 종료

# --- 스크립트가 백그라운드에서 실행될 경우, 메인 프로세스가 종료되지 않도록 ---
# 이 스크립트가 백그라운드에서 계속 실행되어야 한다면 이 부분은 유지해야 합니다.
# 만약 스크립트가 한 번 실행되고 바로 종료되어도 괜찮다면 아래 while True 루프를 제거해도 됩니다.
print("\nPython 스크립트가 백그라운드에서 실행됩니다. 주기적으로 작업을 수행하거나 대기합니다.")
while True:
    # 이 부분에 DB 연결 외에 파이썬 스크립트가 수행할 다른 작업을 추가할 수 있습니다.
    # 예: 로그 수집, 파일 처리, 다른 API 호출 등
    print(f"Python 스크립트 실행 중... ({time.strftime('%Y-%m-%d %H:%M:%S')})")
    time.sleep(300) # 5분 대기
