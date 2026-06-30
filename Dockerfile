FROM eclipse-temurin:25-jdk-alpine

ARG MAVEN_VERSION=3.9.11
ARG USER_HOME_DIR="/nonroot"
ARG SHA=bcfe4fe305c962ace56ac7b5fc7a08b87d5abd8b7e89027ab251069faebee516b0ded8961445d6d91ec1985dfe30f8153268843c89aa392733d1a3ec956c9978
ARG BASE_URL="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.11"
ARG SHA_ASC=8f8dd2c8323adb17009407875a426c72e72dbe5b74059a619071f92446abc9575d4eee81f9ac1f2b9772cc71f900a299dded61eb4a5c14c2bd87d0518e2ec6b4

ENV MAVEN_HOME=/usr/share/maven
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

RUN addgroup -S nonroot \
 && adduser -S nonroot -G nonroot \
 && mkdir -p /nonroot/.m2/repository \
 && apk --no-cache add gnupg \
 && wget --max-redirect=1 "${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && echo "${SHA}" "apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum -c - \
 && wget --max-redirect=0 "${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" \
 && echo "${SHA_ASC}"  "apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc" | sha512sum -c - \
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