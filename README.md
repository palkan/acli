[![Build Status](https://travis-ci.org/palkan/acli.svg?branch=master)](https://travis-ci.org/palkan/acli)

# Action Cable CLI

ACLI is Action Cable command line interface written in [mRuby](http://mruby.org).

It's a standalone binary which can be used:

- in development to _play_ with Action Cable channels (instead of struggling with browsers)

- for acceptance testing (see [Scenarios](#scenarios))

- for benchmarking.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Checkout [Downloads](https://github.com/palkan/acli/blob/master/DOWNLOADS.md) page for pre-compiled binaries.

Currently only MacOS (x86\_64) and Linux (x86\_64) are supported.
**PRs are welcomed** for other platforms support.

We're also working on the [Homebrew](https://brew.sh/) formula.


## Usage

ACLI is an interactive tool by design, i.e. it is asking you for input if neccessary.
Just run it without any arguments:

```sh
acli

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
```

You can also provide URL and channel info using CLI options:

```sh
acli -u http://example.com/cable -c channel_name
```

You can pass channel params this way for now.

Other commands:

```sh
# Print help
\?

# Quit
\q
```

Other command line options:

```sh
# Print usage
acli -h

# Print version
acli -v

# Quit after M incoming messages
acli -u http://example.com/cable -c channel_name -m M
```

### TODO

- Support HTTP headers

- Reconnect support

- Output formatters (and colorize)

### Scenarios

**Work in progress**

Although ACLI has been designed to be an interactive tool, it would be great to have some automation.
And here come scenarios.

Consider an example:

```yml
# Commands
- subscribe: "echo"
- perform:
    action: "ping"

# Expectations
- receive:
    data:
      message: "pong"
```

and another one:


```yml
# Commands
- subscribe: "clock"

# Expectations
- receive:
    data:
      message: /Current time is .*/
    timeout: 2
    # repeat this step 5 times
    multiplier: 5
```

Running ACLI with scenario:

```sh
acli -u localhost -s echo.yml
```

The exit code is 0 if the scenario passes and 1 otherwise. So it can be used for black-box testing.

## Development

ACLI is built on top of [mruby-cli](http://mruby-cli.org), so it comes with Docker environment configuration.
You can run `docker-compose run compile` or `docker-compose run test`.

You can also build the project _locally_ (on MacOS or Linux): `rake compile` or `rake test`.

### Requirements:

- [libressl](https://www.libressl.org/) (`brew install libressl`)

- [wslay](https://github.com/tatsuhiro-t/wslay) (`brew install wslay`)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/acli.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

