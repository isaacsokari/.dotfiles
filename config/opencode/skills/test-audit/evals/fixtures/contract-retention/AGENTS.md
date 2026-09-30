# Protocol and authorization fixture

Run focused tests with `node --test test/codec.test.mjs` or
`node --test test/access.test.mjs`; run all with `node --test test/*.test.mjs`.
There are no dependencies, build steps, or other required gates.

The v1 consumer requires exactly `v1|<id>\n` as UTF-8 bytes. It cannot accept a
different delimiter or a missing newline. Authorization requires an enabled
admin whose tenant matches the requested resource. These are public contracts.
Work only in this fixture. A review request must leave its files unchanged.
