# 가볍고 안정적인 OpenJDK 17 + Alpine 이미지 사용
FROM eclipse-temurin:17-jdk-alpine

# 환경 변수 설정
ENV TOMCAT_VERSION=9.0.100
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH
ENV MARIADB_CONNECTOR_VERSION=3.3.3

# 필요한 도구 설치 및 Tomcat 설치
RUN apk add --no-cache curl tar && \
    mkdir -p $CATALINA_HOME && \
    curl -fsSL https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    | tar -xz -C /tmp && \
    mv /tmp/apache-tomcat-${TOMCAT_VERSION}/* $CATALINA_HOME && \
    rm -rf /tmp/*

# JDBC 드라이버 다운로드 및 설치
RUN curl -fsSL https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_CONNECTOR_VERSION}/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar \
    -o ${CATALINA_HOME}/lib/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar

# 정적 웹 리소스 및 설정 복사
COPY ./LCN/ $CATALINA_HOME/webapps/ROOT/
COPY ./xml/context.xml $CATALINA_HOME/webapps/manager/META-INF/context.xml
# COPY ./xml/web.xml $CATALINA_HOME/webapps/manager/WEB-INF/web.xml

# 포트 오픈
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]


