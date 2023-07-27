####
# This Dockerfile is used in order to build a container that runs the Quarkus application in native (no JVM) mode.
# It uses a micro base image, tuned for Quarkus native executables.
# It reduces the size of the resulting container image.
# Check https://quarkus.io/guides/quarkus-runtime-base-image for further information about this image.
#
# Before building the container image run:
#
# ./mvnw package -Pnative
#
# Then, build the image with:
#
# docker build -f src/main/docker/Dockerfile.native-micro -t quarkus/code-with-quarkus .
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 quarkus/code-with-quarkus
#
###
FROM registry.redhat.io/quarkus/mandrel-22-rhel8

USER root
RUN yum module enable -y container-tools:rhel8
RUN yum module install -y container-tools:rhel8

RUN pwd
COPY ./ .
RUN ./mvnw clean package -Pnative -Dquarkus.native.container-build=true
RUN ls

WORKDIR /work/

RUN chown 1001 /work \
    && chmod "g+rwX" /work \
    && chown 1001:root /work
COPY --chown=1001:root target/quarkus-app/*-runner /work/application

EXPOSE 8080
USER 1001

CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
