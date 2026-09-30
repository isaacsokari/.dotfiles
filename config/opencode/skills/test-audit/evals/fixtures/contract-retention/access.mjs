export function authorize(user, resourceTenant) {
  if (!user) throw new Error('unauthenticated');
  if (!user.enabled) throw new Error('disabled');
  if (user.role !== 'admin') throw new Error('forbidden');
  return true;
}
