# pkmn-wfc-server

This image is a copy of [Original Source](https://github.com/u1f992/pkmn-wfc-server) - but modified to have several important aspects removed for public release:
- pkmn-classic dependency dropped completely
- debian sources switched to archive
- reliance on existing dumped certs has been removed and scrubbed from history to prevent potential legal issues (though note, the original dockerfile merely *downloaded* them and did NOT distribute).

Additionally to ease usage for people not as familiar with docker several scripts have been added to aid setting the repository up.

1. User should download and install docker as the single dependency.
2. When a user pulls the repository initally they should put their *legally* acquired cert (.p12) file in the repository root.
3. Add any wondercards you would like to distribute to the repository root.
4. Download the pre-built image file from releases (or optionally build from the Dockerfile if familiar)
5. Run `load_image.bat` to load the pre-built image into docker
6. Run `start.bat` to start your server.
7. Run `config.bat` to configure your server (sets up dnsmasq with your IP and sets up your certs)
8. Visit `localhost/?page=admin&section=Dashboard` to white list games (see below)
9. Run `copy_wondercards.bat` to copy and `.myg` wondercard files you would like to send to your game to the server

Docker image based on [CoWFC](https://github.com/EnergyCube/CoWFC) & [Poké Classic Framework](https://github.com/mm201/pkmn-classic-framework).

### Game code (Gen4)

| title | code |
| --- | --- |
| Diamond | ADA |
| Pearl | APA |
| Platinum | CPU |
| HeartGold | IPK |
| SoulSilver | IPG |

## Caution

Since enabled weak-enough SSL auth on purpose, this container is not intended to be published via internet.

## Wondercards

Copied wondercards can be indexed by date and will copy in alphabetical order.  For example if I have two files, 1.myg and 2.myg, setting my calendar to January 1 (year doesn't matter) will send 1.myg and January 2nd will send 2.myg

## Reference

- [Original Source](https://github.com/u1f992/pkmn-wfc-server)
- [dwc_network_server_emulator](https://github.com/EnergyCube/dwc_network_server_emulator)
- [CoWFC](https://github.com/EnergyCube/CoWFC)
- [Poké Classic Framework](https://github.com/mm201/pkmn-classic-framework)
- [nds-constrain't](https://github.com/KaeruTeam/nds-constraint)
