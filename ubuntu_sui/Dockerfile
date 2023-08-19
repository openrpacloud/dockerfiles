# ckeyer/dev:ubuntu-sui
FROM ubuntu:20.04

RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apt update -y && \
    apt install -y curl git-all cmake gcc pkg-config libssl-dev libclang-dev libpq-dev build-essential

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

RUN export PATH=$PATH:/root/.cargo/bin

RUN cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui

RUN cargo install --git https://github.com/move-language/move move-analyzer --branch sui-move --features "address32"




