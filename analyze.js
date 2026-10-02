const fs = require('fs');

if (!fs.existsSync('repomix-output.xml')) {
  console.error('repomix-output.xml not found! Run repomix first.');
  process.exit(1);
}

const content = fs.readFileSync('repomix-output.xml', 'utf8');

// Extract Dart file paths from repomix output
const fileMatches = content.match(/path="([^"]+)"/g) || [];
const dartFiles = fileMatches
  .map(m => m.replace('path="', '').replace('"', ''))
  .filter(f => f.endsWith('.dart'));

const report = `# T20-BedLink Codebase & Architecture Analysis

## 1. Overview & Stack
- **Framework**: Flutter / Dart
- **Backend Services**: Firebase (Authentication, Firestore / Realtime DB)
- **Context Source**: repomix-output.xml

## 2. Detected Dart Files (${dartFiles.length} files in lib/)
${dartFiles.map(f => `- ${f}`).join('\n')}

## 3. Key Modules & Services
- **UI Screens & Widgets**: Located under lib/
- **Firebase Integration**: Configurations present in firebase.json and pubspec.yaml
`;

fs.writeFileSync('APP_EXPLANATION.md', report, 'utf8');
console.log('Successfully created APP_EXPLANATION.md!');
