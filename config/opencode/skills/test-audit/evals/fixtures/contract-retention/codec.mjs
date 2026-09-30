export function encode(id) {
  return Buffer.from(`v1|${id}\n`, 'utf8');
}
