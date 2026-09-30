import assert from 'node:assert/strict';
import test from 'node:test';
import { sendWithRetry } from '../retry.mjs';

test('returns the first successful response', async () => {
  const transport = { send: async () => 'delivered' };
  assert.equal(await sendWithRetry(transport), 'delivered');
});

test('preserves the last transport error on exhaustion', async () => {
  const error = new Error('offline');
  const transport = { send: async () => { throw error; } };
  await assert.rejects(sendWithRetry(transport), (actual) => actual === error);
});
