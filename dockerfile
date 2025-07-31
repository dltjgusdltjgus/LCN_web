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
# MariaDB Connector/J 최신 안정 버전
ENV MARIADB_CONNECTOR_VERSION=3.3.3

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

# --- Spring Boot WAR 파일 복사 (가장 중요!) ---
# Spring Boot 애플리케이션을 반드시 '.war' 파일로 빌드해야 합니다.
# (pom.xml에서 <packaging>jar</packaging>를 <packaging>war</packaging>로 변경하고
# SpringBootServletInitializer를 상속받도록 코드를 수정해야 합니다.)
# 빌드된 WAR 파일을 Tomcat의 webapps 디렉토리에 복사합니다.
# 웹 애플리케이션의 루트 컨텍스트로 배포하려면 이름을 ROOT.war로 지정합니다.
# 'target/' 경로는 Dockerfile이 있는 위치를 기준으로 합니다. WAR 파일 이름을 확인해주세요.
# COPY target/user-registration-app.war $CATALINA_HOME/webapps/ROOT

# 웹 애플리케이션 복사 (이전 LCN 복사 줄)
# 이 줄은 일반적으로 WAR 파일 내부에 정적 리소스가 포함되므로 WAR 배포 시에는
# 중복되거나 충돌할 수 있습니다.
# 만약 LCN이 WAR에 포함되지 않은 독립적인 정적 파일이고 Tomcat이 이를 별도로 서비스해야 한다면 유지합니다.
# 이 경우, WAR 파일 압축 해제 후 LCN 파일이 루트 컨텍스트에 추가됩니다.
COPY ./LCN/ $CATALINA_HOME/webapps/ROOT/
COPY ./xml/context.xml $CATALINA_HOME/webapps/manager/META-INF/context.xml
#COPY ./xml/web.xml $CATALINA_HOME/webapps/manager/WEB-INF/web.xml

# Tomcat의 기본 HTTP 포트 노출
EXPOSE 8080

# Tomcat 시작 (포어그라운드)
# 'exec' 형태를 사용하는 것이 Docker의 시그널 처리에 더 좋습니다.
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
