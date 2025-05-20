const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
exports.deleteExpiredRequests = functions.firestore
    .document("Work_requests/{docId}")
    .onCreate(async (snapshot, context) => {
      const data = snapshot.data();
      const createdAt = data.createdAt;
      const currentTime = admin.firestore.Timestamp.now();
      const fiveMinutesInMillis = 5 * 60 * 1000;
      const diffInMillis = currentTime.toMillis() - createdAt.toMillis();
      if (diffInMillis >= fiveMinutesInMillis) {
        await admin.firestore()
            .collection("Work_requests")
            .doc(context.params.docId)
            .delete();
        console.log("Request deleted due to 5-minute expiration");
      }
      return null;
    },
    );
// Add a newline at the end of the file
