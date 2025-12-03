const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

admin.initializeApp();


const CONFIG_COLLECTION = 'appConfig';
const BOT_CONFIG_DOC = 'telegramBot';
const FIREBASE_CONFIG_DOC = 'firebaseConfig';

exports.getBotToken = functions.region('europe-west3').https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
      }

      const configDoc = await admin
        .firestore()
        .collection(CONFIG_COLLECTION)
        .doc(BOT_CONFIG_DOC)
        .get();

      if (!configDoc.exists) {
        return res.status(404).json({ error: 'Bot token not configured' });
      }

      const config = configDoc.data();
      return res.status(200).json({
        token: config.token,
        botUsername: config.botUsername || null,
      });
    } catch (error) {
      console.error('Error getting bot token:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

exports.getFirebaseConfig = functions.region('europe-west3').https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
      }

      const configDoc = await admin
        .firestore()
        .collection(CONFIG_COLLECTION)
        .doc(FIREBASE_CONFIG_DOC)
        .get();

      if (!configDoc.exists) {
        return res.status(404).json({ error: 'Firebase config not found' });
      }

      const config = configDoc.data();
      return res.status(200).json({
        apiKey: config.apiKey,
        appId: config.appId,
        messagingSenderId: config.messagingSenderId,
        projectId: config.projectId,
        authDomain: config.authDomain,
        storageBucket: config.storageBucket,
      });
    } catch (error) {
      console.error('Error getting Firebase config:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

exports.setBotToken = functions.region('europe-west3').https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
      }

       const authHeader = req.headers.authorization;
       if (!authHeader || !isAdmin(authHeader)) {
         return res.status(403).json({ error: 'Forbidden' });
       }

      const { token, botUsername } = req.body;

      if (!token) {
        return res.status(400).json({ error: 'Token is required' });
      }

      await admin
        .firestore()
        .collection(CONFIG_COLLECTION)
        .doc(BOT_CONFIG_DOC)
        .set({
          token: token,
          botUsername: botUsername || null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

      return res.status(200).json({ success: true, message: 'Bot token updated' });
    } catch (error) {
      console.error('Error setting bot token:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

/**
 * Установить конфигурацию Firebase (только для админов)
 * POST /setFirebaseConfig
 * Body: { apiKey, appId, messagingSenderId, projectId, authDomain, storageBucket }
 */
exports.setFirebaseConfig = functions.region('europe-west3').https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
      }

      // TODO: Добавить проверку авторизации админа

      const {
        apiKey,
        appId,
        messagingSenderId,
        projectId,
        authDomain,
        storageBucket,
      } = req.body;

      if (!apiKey || !appId || !projectId) {
        return res.status(400).json({ error: 'Required fields missing' });
      }

      await admin
        .firestore()
        .collection(CONFIG_COLLECTION)
        .doc(FIREBASE_CONFIG_DOC)
        .set({
          apiKey,
          appId,
          messagingSenderId,
          projectId,
          authDomain,
          storageBucket,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

      return res.status(200).json({ success: true, message: 'Firebase config updated' });
    } catch (error) {
      console.error('Error setting Firebase config:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

