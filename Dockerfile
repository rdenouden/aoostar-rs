FROM ubuntu AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN echo $DEBIAN_FRONTEND
RUN apt update
RUN apt install curl prelink musl build-essential git pkg-config libudev-dev -y
RUN --mount=type=cache,target=/root/.cargo/ \
    --mount=type=cache,target=/src/target \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
WORKDIR /src
ADD src/ /src/src/
ADD Cargo* /src/
ADD fonts/ /src/fonts/
# ADD cfg/ /src/cfg/
ADD img/ /src/img/
RUN --mount=type=cache,target=/root/.cargo/ \
    --mount=type=cache,target=/src/target \
    /root/.cargo/bin/rustup target add x86_64-unknown-linux-musl
RUN --mount=type=cache,target=/root/.cargo/ \
    --mount=type=cache,target=/src/target \
    /root/.cargo/bin/cargo build --release --target x86_64-unknown-linux-musl
RUN --mount=type=cache,target=/root/.cargo/ \
    --mount=type=cache,target=/src/target \
    cp -r /src/target /target
# RUN prelink /target/release/asterctl
CMD ["/bin/bash"]

FROM ubuntu AS consolidation
WORKDIR /app
COPY --from=build /target/x86_64-unknown-linux-musl/release/asterctl /app
# COPY --from=build /src/cfg/ /app/cfg/
COPY --from=build /src/fonts/ /app/fonts/
# CMD [ "bash" ]

FROM scratch AS final
COPY --from=consolidation /app/ /
ENTRYPOINT [ "/asterctl" ]
CMD [ "--demo" ]
# CMD [ "--config", "/cfg/monitor.json" ]
