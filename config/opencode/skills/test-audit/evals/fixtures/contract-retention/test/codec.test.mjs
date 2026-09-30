import assert from 'node:assert/strict';
import test from 'node:test';
import { encode } from '../codec.mjs';

test('encodes the v1 wire format including its newline', () => {
  assert.deepEqual(encode('a7'), Buffer.from([118, 49, 124, 97, 55, 10]));
});
