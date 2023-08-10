![Build](https://github.com/palkan/acli/workflows/Build/badge.svg)

# Action Cable CLI

ACLI is an Action Cable command-line interface written in [mRuby](http://mruby.org).

It's a standalone binary which can be used:

- In development for playing with Action Cable channels (instead of struggling with browsers)

- For monitoring and benchmarking.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Currently only MacOS (x86\_64 and ARM) and Linux (x86\_64) are supported.
**PRs are welcomed** for other platforms support.

### Precompiled binaries

See GitHub [releases](https://github.com/palkan/acli/releases). You can download the latest release by using cURL:

```sh
curl -L https://github.com/palkan/acli/releases/latest/download/acli-`uname -s`-`uname -m` > /usr/local/bin/acli
chmod +x /usr/local/bin/acli
```

You can also find edge (master) builds in [Actions](https://github.com/palkan/acli/actions).

### Homebrew

Coming soon

## Usage

ACLI is an interactive tool by design, i.e., it is asking you for input if necessary.
Just run it without any arguments:

```sh
$ acli

Enter URL:

# After successful connection you receive a message:
Connected to Action Cable at http://example.com/cable
```

Then you can run Action Cable commands:

```sh
# Subscribe to channel (without parameters)
\s channel_name

# Subscribe to channel with params

\s+ channel_name id:1

# or interactively

\s+
Enter channel ID:
...
# Generate params object by providing keys and values one by one
Enter key (or press ENTER to finish):
...
Enter value:
# After successful subscription you receive a message
Subscribed to channel_name


# Performing actions
\p speak message:Hello!

# or interactively (the same way as \s+)
\p+


# Retrieving the channel's history since the specified time

# Relative, for example, 10 minutes ago ("h" and "s" modifiers are also supported)
\h since:10m

# Absolute since the UTC time (seconds)
\h since:1650634535
```

You can also provide URL and channel info using CLI options:

```sh
acli -u http://example.com/cable -c channel_name

# or using full option names
acli --url=http://example.com/cable --channel=channel_name

# you can omit scheme and even path (/cable is used by default)
acli -u example.com
```

To pass channel params use `--channel-params` option:

```sh
acli -u http://example.com/cable -c ChatChannel --channel-params=id:1,name:"Jack"
```

You can pass additional request headers:

```sh
acli -u example.com --headers="x-api-token:secret,cookie:username=john"
```

Other commands:

```sh
# Print help
\?

# Quit
\q
```

Other command-line options:

```sh
# Print usage
acli -h

# Print version
acli -v

# Quit after M incoming messages (excluding pings and system messages)
acli -u http://example.com/cable -c channel_name --quit-after=M

# Enabling PONG commands in response to PINGs
acli -u http://example.com/cable --pong
```

## Development

We have Docker & [Dip](https://github.com/bibendi/dip) configuration for development:

```sh
# initial provision
dip provision

# run rake tasks
dip rake test

# or open a console within a container
dip bash
```

You can also build the project _locally_ (on MacOS or Linux): `rake compile` or `rake test`.

### Requirements

- [Ruby Next](https://github.com/ruby-next/ruby-next) (`gem install ruby-next`)

- [libressl](https://www.libressl.org/) (`brew install libressl`)

- [wslay](https://github.com/tatsuhiro-t/wslay) (`brew install libressl`)

- [childprocess](https://github.com/enkessler/childprocess) gem for testing (`gem install childprocess`)

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/palkan/acli).

## License

The gem is available as open-source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
