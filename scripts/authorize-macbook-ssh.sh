#!/bin/sh
# Authorize the supplied MacBook SSH public key for the current account.
# Run as the intended target user, without sudo.
set -eu
umask 077

public_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a+jX5VNYM7gUffXcho9e1LKuLYfTU7nNlZ8PPVgw8HYJG1DKf2ScDYOzAYMDuDRVL9L9k1a9+aBjQJllrM6M+A/1hQqN2om2jw7PKtp10I04BoJMSTtMRCMptsH1qnFi4Ac59dtkek+ZrEl1jkdAk5ghDmZjFipvLQ/5lJ5bWcj7UngCQuclDXlxDH44MaUA6ivtYD2xyL2/z8BCIyKxgR40rZtMUsGlYtu3of3cZiSAbXePJAyZsGI8v85jDqRlQYdhCG0RoeINyGIPqjt9cc/voCIxt+JO2XY3Fg4YFGO9pYNQHcFSzcIO40V6fN6aiBafVKkfBHszj5lYGhBEi4jdTm8nEaq0r10so0RydmyGgN2Lw/mqIfT2qf5D/jtUBjZTexc21/nD+oD+OqyRaTX2YxpMOlrxOxIk6hH1VApmkPEWatEPqnYRfARESXoGQ2ty//0uFQe2D3TUcQGW3x+rJVpvhZnNCmztu/63b85pBObfm1IqTEGJfcqJTC7IvJbRiM8H16sf1IOvULQsCcj6rFJ5JYre+PN2U/tT4NBJ1P0bIEO/PTZsMKmLZtZAQpWihK3SxV15IapHgIwKsqTPlB6v34GmTcVPCvF+6aJCXJxcabtdiSnNZoEk0+JhczGofF7TIYNqhEa/7bVDSfAkBwcLcsqDVDFRgCd1Cw== abcgfsmile@gmail.com'
ssh_dir="${HOME:?HOME is not set}/.ssh"
authorized_keys="$ssh_dir/authorized_keys"

mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"
touch "$authorized_keys"
chmod 600 "$authorized_keys"

if grep -Fqx "$public_key" "$authorized_keys"; then
    printf 'SSH key already authorized for %s.\n' "$(id -un)"
else
    printf '%s\n' "$public_key" >> "$authorized_keys"
    printf 'SSH key authorized for %s.\n' "$(id -un)"
fi
