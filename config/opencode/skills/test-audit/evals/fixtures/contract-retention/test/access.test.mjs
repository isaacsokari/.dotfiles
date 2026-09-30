import assert from 'node:assert/strict';
import test from 'node:test';
import { authorize } from '../access.mjs';

test('allows an enabled admin in the resource tenant', () => {
  assert.equal(authorize({ enabled: true, role: 'admin', tenant: 'a' }, 'a'), true);
});

test('rejects a viewer role', () => {
  assert.throws(() => authorize({ enabled: false, role: 'viewer', tenant: 'a' }, 'a'));
});

test('rejects cross-tenant admin access', () => {
  assert.throws(
    () => authorize({ enabled: true, role: 'admin', tenant: 'a' }, 'b'),
    /tenant/,
  );
});
