import fs from 'fs';
import path from 'path';
import os from 'os';

const sourceDir = path.join(process.cwd(), 'resolve');
const targetBaseDir = path.join(
  os.homedir(),
  'AppData',
  'Roaming',
  'Blackmagic Design',
  'DaVinci Resolve',
  'Support',
  'Fusion',
  'Scripts',
  'Comp'
);

function copyFolderSync(from, to) {
  if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });
  fs.readdirSync(from).forEach((element) => {
    if (fs.lstatSync(path.join(from, element)).isFile()) {
      fs.copyFileSync(path.join(from, element), path.join(to, element));
    } else {
      copyFolderSync(path.join(from, element), path.join(to, element));
    }
  });
}

console.log('🚀 Iniciando instalação dos scripts do EditCOPY...');

if (os.platform() !== 'win32') {
  console.error('❌ Erro: Este script de instalação automatizada suporta apenas Windows.');
  process.exit(1);
}

try {
  if (!fs.existsSync(sourceDir)) {
    console.error(`❌ Erro: Pasta de origem não encontrada: ${sourceDir}`);
    process.exit(1);
  }

  copyFolderSync(sourceDir, targetBaseDir);
  
  console.log('\n✅ Sucesso! Scripts instalados em:');
  console.log(`📂 ${targetBaseDir}\n`);
  console.log('Próximos passos:');
  console.log('1. Reinicie o DaVinci Resolve (se estiver aberto).');
  console.log('2. Vá em Workspace -> Scripts -> EditCOPY.');
  console.log('3. Execute "npm run resolve:test" para validar a comunicação.');
} catch (error) {
  console.error('❌ Erro durante a instalação:', error.message);
  process.exit(1);
}
