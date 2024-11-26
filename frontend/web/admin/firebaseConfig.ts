import { initializeApp } from 'firebase/app';
// Importez d'autres services Firebase dont vous avez besoin
// e.g. import { getAuth } from 'firebase/auth';

// Configuration Firebase copié à partir de la console
const firebaseConfig = {
  apiKey: "AIzaSyD58ROgpRqOXSKQ7Ng5-N57fBnTux55DtA",
  authDomain: "alpha-79c09.firebaseapp.com",
  projectId: "alpha-79c09",
  storageBucket: "alpha-79c09.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abcdefg12345"
};

// Initialisation de Firebase
const app = initializeApp(firebaseConfig);

// Exportez les services Firebase nécessaires
export default app;