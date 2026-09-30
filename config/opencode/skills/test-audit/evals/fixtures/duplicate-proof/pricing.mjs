function roundCents(value) {
  return Math.round(value * 100) / 100;
}

export function quote(price, discount) {
  return { total: roundCents(price * (1 - discount)) };
}

export const __testRound = roundCents;
