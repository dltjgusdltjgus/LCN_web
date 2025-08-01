# Ubuntu 18.04를 기본 이미지로 사용
FROM ubuntu:18.04

# maintainer 레이블 설정
LABEL maintainer="Young Chul Kim <ychkim@lotte.net>"

# 환경 변수 설정
ENV TOMCAT_VERSION=9.0.100
ENV CATALINA_HOME=/usr/local/tomcat
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$CATALINA_HOME/bin:$PATH

# MariaDB JDBC 드라이버 버전 설정 (이전 MYSQL_CONNECTOR_VERSION에서 변경됨)
ENV MARIADB_CONNECTOR_VERSION=3.3.3
 # MariaDB Connector/J 최신 안정 버전
ENV DB_ENDPOINT=lcn-kr-db.c9g48swe6aab.ap-northeast-2.rds.amazonaws.com
ENV DB_USERNAME=admin
ENV DB_PASSWORD=powerlcn

# 1. 패키지 설치 및 JDK 설치
# apt-get update와 install/upgrade를 한 줄에 두어 빌드 캐싱 효율성 높임
# wget과 curl (JDBC 다운로드 시 사용), 그리고 필수적인 net-tools (네트워크 유틸리티) 설치
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    curl \
    net-tools && \
    # 이미지 크기를 줄이기 위해 apt 캐시 정리 (install 명령어와 같은 RUN 레이어에 두면 효율적)
    rm -rf /var/lib/apt/lists/*

# 2. Tomcat 설치 및 구성
RUN mkdir -p $CATALINA_HOME && \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz && \
    tar xvfz /tmp/tomcat.tar.gz -C /tmp && \
    mv /tmp/apache-tomcat-${TOMCAT_VERSION}/* $CATALINA_HOME && \
    rm -rf /tmp/apache-tomcat-${TOMCAT_VERSION} /tmp/tomcat.tar.gz

# 3. MariaDB JDBC 드라이버 다운로드 및 Tomcat의 lib 디렉토리에 복사 (DB 연결을 위한 핵심 부분)
# 이 드라이버는 Tomcat 컨테이너의 모든 웹 애플리케이션에서 사용 가능해집니다.
# (Spring Boot WAR에 JDBC 드라이버가 포함될 것이므로 이 단계는 보통 불필요할 수 있습니다.
# 하지만 Tomcat의 공유 라이브러리 목적으로 유지할 수는 있습니다.)
RUN wget https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_CONNECTOR_VERSION}/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar -O ${CATALINA_HOME}/lib/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar

# 패키지 목록 업데이트 및 Python 3 설치
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# (선택 사항) 'python' 명령어를 'python3'에 링크 (호환성 목적)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# 이제 Python을 사용할 수 있습니다.
WORKDIR /app
COPY ./*.py /app
#COPY ./LCN/ $CATALINA_HOME/webapps/ROOT/
COPY ./xml/context.xml $CATALINA_HOME/webapps/manager/META-INF/context.xml

# Tomcat의 기본 HTTP 포트 노출
EXPOSE 8080

# Tomcat 시작 (포어그라운드)
# 'exec' 형태를 사용하는 것이 Docker의 시그널 처리에 더 좋습니다.
# CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
