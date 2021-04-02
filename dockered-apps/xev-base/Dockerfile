FROM ubuntu:20.10

RUN apt-get update && apt-get install -y x11-utils sudo iproute2

# Replace 1000 with your user / group id
RUN useradd -d /home/developer -m -U developer && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

USER developer
ENV HOME /home/developer
CMD /usr/bin/xev
