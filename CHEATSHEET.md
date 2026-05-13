# Main

## Rebuild

```bash
sudo nixos-rebuild switch --flake /path/to/config-directory#pc
```

## Update

```bash
nix flake update
```

um einen spezifischen flake input upzudaten:

```bash
nix flake update
```

## Generationen löschen

> [!NOTE]
> Löscht alle Generationen die älter als 30 Tage sind.

```bash
sudo nix-collect-garbage --delete-older-than 30d
```

## Garbage leeren

> [!WARNING]
> Das löscht auch ALLE alten Generationen!

```bash
sudo nix-collect-garbage -d
```

# Utility

## Top-Speicher Verbraucher

```bash
nix-store --query --requisites /run/current-system | xargs -n1 nix-store --query --size | sort -n | tail -20
```

## Größe des Systems

```bash
nix --extra-experimental-features nix-command path-info -Sh /run/current-system
```

## Top 20 Pakete

```bash
nix-store --query --requisites /run/current-system \
 | xargs -n1 nix --extra-experimental-features nix-command path-info -Sh \
 | sort -h \
 | tail -20
```

## Temporär Port 22 freischalten firewall

```bash
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
```
