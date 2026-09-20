#!/usr/bin/env node
// Copies package.json's version into .claude-plugin/plugin.json.
// Runs as part of `npm run version`, immediately after `changeset version`.
// With --check it changes nothing and exits 1 if the two versions differ.

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const pluginPath = join(repo, ".claude-plugin", "plugin.json");

const { version } = JSON.parse(readFileSync(join(repo, "package.json"), "utf8"));
const source = readFileSync(pluginPath, "utf8");
const plugin = JSON.parse(source);

if (plugin.version === version) {
  console.log(`plugin.json version is ${version} (already in sync)`);
  process.exit(0);
}

if (process.argv.includes("--check")) {
  console.error(
    `plugin.json version is ${plugin.version ?? "(missing)"}, package.json is ${version}. Run \`node scripts/sync-plugin-version.mjs\`.`,
  );
  process.exit(1);
}

if (plugin.version === undefined) {
  // No existing "version" line to replace — insert one right after "name".
  const updated = source.replace(
    /("name"\s*:\s*"[^"]*",?)/,
    `$1\n  "version": "${version}",`,
  );

  if (JSON.parse(updated).version !== version) {
    console.error(`Could not find a "name" field to insert a version after in ${pluginPath}.`);
    process.exit(1);
  }

  writeFileSync(pluginPath, updated);
  console.log(`plugin.json version field added: ${version}`);
  process.exit(0);
}

// Rewrite only the version line, to keep the key order and the formatting.
const updated = source.replace(
  /("version"\s*:\s*")[^"]*(")/,
  `$1${version}$2`,
);

if (JSON.parse(updated).version !== version) {
  console.error(`Could not find a version field to replace in ${pluginPath}.`);
  process.exit(1);
}

writeFileSync(pluginPath, updated);
console.log(`plugin.json version ${plugin.version} -> ${version}`);
