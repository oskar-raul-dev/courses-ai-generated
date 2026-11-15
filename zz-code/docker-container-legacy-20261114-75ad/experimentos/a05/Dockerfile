FROM legacy-node-toolchain:phase15
ARG APP_UID=1000
ARG APP_GID=1000

RUN groupadd --gid "${APP_GID}" dev \
    && useradd --uid "${APP_UID}" --gid "${APP_GID}" --create-home --shell /bin/bash dev \
    && mkdir -p /workspace \
    && chown -R "${APP_UID}:${APP_GID}" /workspace

USER dev
WORKDIR /workspace
