.PHONY: build configure prepare clean

build: configure
	docker run --rm -t --privileged -v $(PWD)/vyos-build:/vyos -w /vyos vyos/vyos-build:current make iso
	mv vyos-build/build/*.iso ./build

configure: prepare
	docker run --rm -t --privileged -v $(PWD)/vyos-build:/vyos -w /vyos vyos/vyos-build:current ./configure --architecture amd64 --custom-apt-key ./tailscale.gpg --custom-apt-entry "deb https://pkgs.tailscale.com/stable/debian buster main" --custom-package "tailscale" --build-comment "VyOS with Tailscale" --build-type production --version 1.4-rolling-`date +%Y%m%d%H%M`

prepare:
	cp tailscale/tailscale.gpg vyos-build/tailscale.gpg

	mkdir -p vyos-build/data/live-build-config/includes.chroot/etc/default
	cp tailscale/tailscaled vyos-build/data/live-build-config/includes.chroot/etc/default/tailscaled

	mkdir -p vyos-build/data/live-build-config/includes.chroot/etc/systemd/system/tailscaled.service.d
	cp tailscale/tailscaled.service vyos-build/data/live-build-config/includes.chroot/etc/systemd/system/tailscaled.service.d/tailscaled.service

clean:
	rm -rf ./build
