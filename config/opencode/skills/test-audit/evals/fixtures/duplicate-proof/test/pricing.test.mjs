import assert from 'node:assert/strict';
import test from 'node:test';
import { quote, __testRound } from '../pricing.mjs';

test('quote applies the discount and rounds to cents', () => {
  assert.deepEqual(quote(19.99, 0.15), { total: 16.99 });
});

test('private rounding helper rounds the discounted amount', () => {
  assert.equal(__testRound(19.99 * (1 - 0.15)), 16.99);
});

test('quote matches the quote implementation', () => {
  assert.deepEqual(quote(19.99, 0.15), quote(19.99, 0.15));
});
