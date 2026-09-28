// Obfuscate the built mod.js before publishing: mangled identifiers +
// base64 string array, no control-flow flattening (keeps game loop fast).
const JavaScriptObfuscator = require('javascript-obfuscator');
const fs = require('fs');

const src = fs.readFileSync(process.argv[2], 'utf8');
const res = JavaScriptObfuscator.obfuscate(src, {
  compact: true,
  simplify: true,
  renameGlobals: false,
  renameProperties: false,
  identifierNamesGenerator: 'mangled-shuffled',
  stringArray: true,
  stringArrayEncoding: ['base64'],
  stringArrayThreshold: 1,
  stringArrayRotate: true,
  stringArrayShuffle: true,
  splitStrings: false,
  controlFlowFlattening: false,
  deadCodeInjection: false,
  selfDefending: true,
  debugProtection: false,
  disableConsoleOutput: false,
  transformObjectKeys: false,
  unicodeEscapeSequence: false,
  numbersToExpressions: false,
  target: 'browser'
});
fs.writeFileSync(process.argv[3], res.getObfuscatedCode());
