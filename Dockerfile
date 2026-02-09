#FROM debian:buster-slim
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

LABEL description="SinusBot - TeamSpeak 3 and Discord music bot"
LABEL version="1.0.2"

# Install dependencies and clean up afterwards
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    jq \
    less \
    libasound2 \
    libegl1-mesa \
    libglib2.0-0 \
    libnss3 \
    libpci3 \
    libxcomposite-dev \
    libxcursor1 \
    libxkbcommon0 \
    libxslt1.1 \
    locales \
    python3 \
    python3-pip \
    python3-venv \
    procps \
    unzip \
    x11vnc \
    xvfb \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*


# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /opt/sinusbot

ADD installer.sh .
ADD files/ ./files/
RUN chmod 755 installer.sh

# Download/Install SinusBot
RUN bash installer.sh sinusbot

# Download/Install yt-dlp
RUN bash installer.sh yt-dlp

# Download/Install Text-to-Speech
RUN bash installer.sh text-to-speech

# Download/Install TeamSpeak Client
RUN bash installer.sh teamspeak-3.5.6

RUN rm -rf files
ADD entrypoint.sh .
RUN chmod 755 entrypoint.sh

EXPOSE 8087

VOLUME ["/opt/sinusbot/data", "/opt/sinusbot/scripts"]

ENTRYPOINT ["/opt/sinusbot/entrypoint.sh"]

HEALTHCHECK --interval=1m --timeout=10s \
    CMD curl --no-keepalive -f http://localhost:8087/api/v1/botId || exit 1