# Change log

## master

## 0.6.0 (2023-08-09)

- Support pongs. ([@palkan][])

Enable pongs by providing the `--pong` optipn.

- Show messages meta information (stream ID, offset, etc.). ([@palkan][])

- Add `\h offset:<N>` support.

## 0.5.0 (2023-02-28)

- Add `--debug` option to print debug information. ([@palkan][])

- Fix URL normalization (do not downcase, 'cause it can break query parameters). ([@palkan][])

## 0.4.1 (2022-08-10)

- Add history (`\h`) command. ([@palkan][])

The history command only allows to fetch messages from the specified time.

## 0.4.0 (2021-05-20)

- Add Msgpack support (`--msgpack`). ([@palkan][])

- Add WS sub-protocols support. ([@palkan][])

- Upgrade to mruby 3.0. ([@palkan][])

## 0.3.1 (2020-06-30)

- Add `--channel-params` option. ([@palkan][])

Now you can connect and subscribe to a parameterized channel via a single command.

- Fix using namespaced Ruby classes as channel names. ([@palkan][])

- Handle `reject_subscription` message. ([@palkan][])

## 0.3.0 (2020-04-21)

- Handle `disconnect` messages. ([@palkan][])

- Add HTTP headers support. ([@palkan][])

- Remove `-m` and add `--quit-after` option. ([@palkan][])

- Fix query string support. ([@palkan][])

## 0.2.0 (2017-06-14)

- Add TLS support. ([@palkan][])

Support connection to secure endpoints, i.e. `acli -u wss://example.com/cable`.

[@palkan]: https://github.com/palkan
