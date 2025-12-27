#!/usr/bin/env node

/**
 * 🔍 Script de vérification pré-déploiement Netlify
 * Vérifie que tous les fichiers nécessaires sont en place
 */

const fs = require('fs');
const path = require('path');

const checks = [
  {
    name: 'next.config.js - output: export',
    file: 'next.config.js',
    check: (content) => content.includes("output: 'export'"),
  },
  {
    name: 'netlify.toml - publish: out',
    file: 'netlify.toml',
    check: (content) => content.includes('publish = "out"'),
  },
  {
    name: 'public/_redirects existe',
    file: 'public/_redirects',
    check: (content) => content.includes('/* /index.html 200'),
  },
  {
    name: '.blog-cache/slugs.json existe',
    file: '.blog-cache/slugs.json',
    check: (content) => {
      try {
        const data = JSON.parse(content);
        return data.slugs && Array.isArray(data.slugs);
      } catch {
        return false;
      }
    },
  },
  {
    name: 'out/ répertoire généré',
    file: 'out/index.html',
    check: (content) => content.includes('<!DOCTYPE html>'),
  },
];

console.log('\n🔍 Vérification pré-déploiement Netlify\n');

let allPassed = true;

checks.forEach((check) => {
  const filePath = path.join(process.cwd(), check.file);

  try {
    if (!fs.existsSync(filePath)) {
      console.log(`❌ ${check.name}`);
      console.log(`   Fichier manquant: ${check.file}\n`);
      allPassed = false;
      return;
    }

    const content = fs.readFileSync(filePath, 'utf-8');

    if (check.check(content)) {
      console.log(`✅ ${check.name}`);
    } else {
      console.log(`❌ ${check.name}`);
      console.log(`   Contenu invalide: ${check.file}\n`);
      allPassed = false;
    }
  } catch (error) {
    console.log(`❌ ${check.name}`);
    console.log(`   Erreur: ${error.message}\n`);
    allPassed = false;
  }
});

console.log('');

if (allPassed) {
  console.log('✅ Tous les vérifications sont passées !');
  console.log('\n📝 Prochaines étapes:');
  console.log('1. git add .');
  console.log('2. git commit -m "fix: static export for Netlify"');
  console.log('3. git push origin main');
  console.log('\nNetlify redéploiera automatiquement.\n');
  process.exit(0);
} else {
  console.log('❌ Certaines vérifications ont échoué.');
  console.log('Veuillez corriger les problèmes avant de déployer.\n');
  process.exit(1);
}
