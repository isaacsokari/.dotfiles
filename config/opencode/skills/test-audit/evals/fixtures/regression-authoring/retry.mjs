export async function sendWithRetry(transport, { maxAttempts = 3 } = {}) {
  let lastError;
  for (let attempt = 1; attempt < maxAttempts; attempt++) {
    try {
      return await transport.send();
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}
