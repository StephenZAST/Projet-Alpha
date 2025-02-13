import { exec } from 'child_process';
import path from 'path';
import fs from 'fs';

const runTests = async () => {
  try {
    // 1. Initialiser la base de données de test
    console.log('Initializing test database...');
    const sqlScript = fs.readFileSync(
      path.join(__dirname, 'sql', 'init-test-data.sql'),
      'utf8'
    );
    
    // Exécuter le script SQL
    await executeSQL(sqlScript);

    // 2. Exécuter les tests Postman
    console.log('Running Postman tests...');
    const collectionPath = path.join(__dirname, 'postman', 'article-service-prices.collection.json');
    const envPath = path.join(__dirname, 'postman', 'article-service.environment.json');

    await executePostmanTests(collectionPath, envPath);

    console.log('Tests completed successfully!');
  } catch (error) {
    console.error('Error running tests:', error);
    process.exit(1);
  }
};

const executeSQL = (script: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    // Utiliser psql ou un autre outil pour exécuter le script
    const command = `psql -U ${process.env.DB_USER} -d ${process.env.DB_NAME} -f -`;
    
    const psql = exec(command);
    psql.stdin?.write(script);
    psql.stdin?.end();

    psql.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`SQL script failed with code ${code}`));
    });
  });
};

const executePostmanTests = (collectionPath: string, envPath: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    const command = `newman run "${collectionPath}" -e "${envPath}"`;
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error('Postman tests failed:', stderr);
        reject(error);
      } else {
        console.log(stdout);
        resolve();
      }
    });
  });
};

runTests();
