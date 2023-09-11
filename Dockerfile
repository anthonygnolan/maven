FROM amazoncorretto:17

ARG MAVEN_VERSION=3.9.2
ARG USER_HOME_DIR="/root"
ARG SHA=f68ae58c64431e1a0361359a7f091d39ac8a74d4
ARG BASE_URL="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.2"

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN set -x
RUN yum install -y tar which gzip
RUN yum clean all
RUN rm -rf /var/cache/yum/*
RUN curl -fsSLO --compressed ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN echo "${SHA}  apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha1sum -c -

RUN curl -fsSLO --compressed ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc
RUN export GNUPGHOME="$(mktemp -d)"
RUN for key in ae5a7fb608a0221c ; do \
      gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key" ; \
      done
#RUN gpg --batch --verify apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN mkdir -p ${MAVEN_HOME} ${MAVEN_HOME}/ref
RUN tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C ${MAVEN_HOME} --strip-components=1 \
      # GNUPGHOME may fail to delete even with -rf
      && (rm -rf "$GNUPGHOME" apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc apache-maven-${MAVEN_VERSION}-bin.tar.gz || true) \
      && ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn \
      # smoke test
      && mvn --version

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]