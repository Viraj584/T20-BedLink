const fs = require('fs');
const filePath = 'web/index.html';

if (!fs.existsSync(filePath)) {
  console.error('web/index.html not found! Make sure you ran flutter create . --platforms web');
  process.exit(1);
}

let content = fs.readFileSync(filePath, 'utf8');

const firebaseScripts = [
  '<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>',
  '<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>',
  '<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>'
].join('\n  ');

if (!content.includes('firebase-app-compat.js')) {
  content = content.replace('</head>', `  ${firebaseScripts}\n</head>`);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Successfully injected Firebase scripts into web/index.html!');
} else {
  console.log('Firebase scripts are already present in web/index.html.');
}
