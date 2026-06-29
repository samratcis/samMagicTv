import { cp, mkdir, rm, stat } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '..', '..');
const sourceDist = join(repoRoot, 'streamvault', 'dist');

const targets = {
  tizen: join(repoRoot, 'platforms', 'tizen', 'www', 'dist'),
  webos: join(repoRoot, 'platforms', 'webos', 'www', 'dist'),
};

const requestedTargets = process.argv.slice(2);
const targetNames = requestedTargets.length ? requestedTargets : Object.keys(targets);

for (const targetName of targetNames) {
  if (!targets[targetName]) {
    throw new Error(`Unknown TV package target "${targetName}". Expected one of: ${Object.keys(targets).join(', ')}`);
  }
}

try {
  const distStat = await stat(sourceDist);
  if (!distStat.isDirectory()) {
    throw new Error(`${sourceDist} is not a directory`);
  }
} catch (error) {
  throw new Error(`Build output not found at ${sourceDist}. Run "npm run build" in streamvault first.`, {
    cause: error,
  });
}

for (const targetName of targetNames) {
  const destination = targets[targetName];
  await rm(destination, { recursive: true, force: true });
  await mkdir(destination, { recursive: true });
  await cp(sourceDist, destination, { recursive: true });
  console.log(`Copied streamvault/dist -> ${destination}`);
}
