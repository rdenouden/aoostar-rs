FROM ubuntu AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN echo $DEBIAN_FRONTEND
RUN apt update
RUN apt install curl prelink musl build-essential git pkg-config libudev-dev -y
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
WORKDIR /src
ADD src/ /src/src/
ADD Cargo* /src/
ADD fonts/ /src/fonts/
ADD cfg/ /src/cfg/
ADD img/ /src/img/
RUN /root/.cargo/bin/rustup target add x86_64-unknown-linux-musl
RUN /root/.cargo/bin/cargo build --release --target x86_64-unknown-linux-musl
RUN cp -r /src/target /target
CMD ["/bin/bash"]

FROM alpine AS consolidation
WORKDIR /app
COPY --from=build /target/x86_64-unknown-linux-musl/release/asterctl /app
COPY --from=build /src/cfg/ /app/cfg/
COPY --from=build /src/fonts/ /app/fonts/

FROM scratch AS final
COPY --from=consolidation /app/ /
ENTRYPOINT [ "/asterctl" ]
CMD [ "--demo", "--config", "/cfg/monitor.json" ]
