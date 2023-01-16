.PHONY: build configure prepare clean

build: prepare
	docker run --rm -t --privileged -v $(PWD)/vyos-build:/vyos -w /vyos vyos/vyos-build@sha256:d99cf3632841a426f5718db22db2c0b49b744354b5311e2ecca94f6b1a04080a sudo ./build-vyos-image iso --architecture amd64 --custom-apt-key ../tailscale.gpg --custom-apt-entry "deb https://pkgs.tailscale.com/stable/debian bullseye main" --custom-package "tailscale" --build-comment "VyOS with Tailscale" --build-type release --version 1.4-rolling-`date +%Y%m%d%H%M`
	mkdir -p ./build
	mv vyos-build/build/vyos-*.iso ./build

prepare:
	cp tailscale/tailscale.gpg vyos-build/tailscale.gpg

	mkdir -p vyos-build/data/live-build-config/includes.chroot/etc/default
	cp tailscale/tailscaled vyos-build/data/live-build-config/includes.chroot/etc/default/tailscaled

	mkdir -p vyos-build/data/live-build-config/includes.chroot/etc/systemd/system/tailscaled.service.d
	cp tailscale/override.conf vyos-build/data/live-build-config/includes.chroot/etc/systemd/system/tailscaled.service.d/override.conf

clean:
	rm -rf ./build
