# Change log

## master

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
