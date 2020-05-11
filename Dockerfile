FROM gradle:6.0.1-jdk8 AS build
COPY --chown=gradle:gradle . /home/gradle/src

ARG NEXUS_USER
ARG NEXUS_PASSWORD
ARG NEXUS_MAVEN_PUBLIC_URL
ARG NEXUS_MAVEN_RELEASES_URL
ARG NEXUS_MAVEN_SNAPSHOTS_URL

ENV NEXUS_USER $NEXUS_USER
ENV NEXUS_PASSWORD $NEXUS_PASSWORD
ENV NEXUS_MAVEN_PUBLIC_URL $NEXUS_MAVEN_PUBLIC_URL
ENV NEXUS_MAVEN_RELEASES_URL $NEXUS_MAVEN_RELEASES_URL
ENV NEXUS_MAVEN_SNAPSHOTS_URL $NEXUS_MAVEN_SNAPSHOTS_URL

WORKDIR /home/gradle/src

ADD script_to_set_args_buildfile.sh .
RUN ./script_to_set_args_buildfile.sh

RUN gradle build --no-daemon -x test

FROM openjdk:8-jdk-alpine
EXPOSE 8080
EXPOSE 8081
RUN mkdir /app
COPY --from=build /home/gradle/src/build/libs/*.jar /app/springtwo.jar
ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-Djava.security.egd=file:/dev/./urandom","-jar","/app/springtwo.jar"]
