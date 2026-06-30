FROM eclipse-temurin:25-jdk-alpine

ARG MAVEN_VERSION=3.9.11
ARG USER_HOME_DIR="/nonroot"
ARG SHA=c084cde986ba878da4370bde009ab0a0a1936343
ARG BASE_URL="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.11"
ARG SHA_ASC=5f74a7dd636c5e226552e3842bb78e88534d405d

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN addgroup -S nonroot \
 && adduser -S nonroot -G nonroot \
 && mkdir -p /nonroot/.m2/repository \
 && apk --no-cache add gnupg \
 && wget "${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && echo "${SHA}" "apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha1sum -c - \
 && wget "${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" \
 && echo "${SHA_ASC}"  "apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" | sha1sum -c - \
 && export GNUPGHOME="$(mktemp -d)" \
 && for key in ae5a7fb608a0221c ; do \
      gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
 && mkdir -p "${MAVEN_HOME}/ref" \
 && tar -xzf "apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C "${MAVEN_HOME}" --strip-components=1 \
 && rm -rf "$GNUPGHOME"  || true \
 && rm -rf "apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" "apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && ln -s "${MAVEN_HOME}/bin/mvn" "/usr/bin/mvn" \
 && mvn --version

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

USER nonroot

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]