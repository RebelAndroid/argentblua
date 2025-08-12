FROM rust:1.89.0-trixie as rust-builder
RUN apt-get -qq update
RUN apt-get -qq install -y libgtk-layer-shell-dev
RUN apt-get -qq install -y libgtk-3-dev
RUN apt-get -qq install -y build-essential
RUN wget --quiet https://github.com/DorianRudolph/sirula/archive/refs/tags/v1.1.0.tar.gz
RUN tar -xzf v1.1.0.tar.gz
RUN rm v1.1.0.tar.gz
WORKDIR sirula-1.1.0
RUN cargo install --quiet --path .

FROM quay.io/fedora/fedora-silverblue:42

RUN rpm-ostree install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
RUN rpm-ostree install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
RUN rpm-ostree uninstall ffmpeg-free libavcodec-free libavdevice-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free
RUN rpm-ostree install ffmpeg intel-media-driver

COPY etc /etc

RUN systemctl enable rpm-ostreed-automatic.timer
RUN systemctl enable sshd.service

RUN rpm-ostree install tailscale
RUN systemctl enable tailscaled.service

RUN rpm-ostree install waydroid
RUN systemctl enable waydroid-container.service

RUN rpm-ostree install dbus-x11 qemu qemu-user-static qemu-user-binfmt virt-manager libvirt qemu qemu-user-static qemu-user-binfmt edk2-ovmf
RUN rpm-ostree install adw-gtk3-theme papirus-icon-theme
RUN rpm-ostree install powertop iotop
RUN rpm-ostree install docker-ce
RUN rpm-ostree install fish alacritty

RUN rpm-ostree install micro

RUN rpm-ostree install sway
RUN rpm-ostree install rofi

COPY --from=rust-builder /sirula-1.1.0/target/release /usr/bin


RUN mkdir /nix

RUN rm -rf /tmp/* /var/*
RUN ostree container commit
