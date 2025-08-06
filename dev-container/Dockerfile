FROM registry.cn-beijing.aliyuncs.com/wa/hub:cuda_12.4.1-torch-2.7

RUN apt update && \
    apt install -y libgomp1 git make libgl1 libglib2.0-0 gcc python3-dev build-essential openssh-server vim less  python3-pip iputils-ping && \
    apt autoclean && \
    apt autoremove -y && \
    rm -rf /var/cache/apt/*.bin

RUN sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["sh", "-c", "mkdir -p /run/sshd && /usr/sbin/sshd -D"]

