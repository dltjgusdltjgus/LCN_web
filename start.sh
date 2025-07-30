#!/bin/bash
python3 /app/script.py & # Python 스크립트를 백그라운드로 실행
/usr/local/tomcat/bin/catalina.sh run # Tomcat을 포어그라운드로 실행 (이 프로세스가 컨테이너의 메인 프로세스가 됨)
