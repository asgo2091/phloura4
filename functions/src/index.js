const { onCall, HttpsError } = require("firebase-functions/v2/https");

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

const PACKAGE_NAME = "se.asgoit.phloura";
const PRODUCT_ID = "phloura_pro";

exports.verifyPurchase = onCall(
  {
    region: "europe-west1",
  },
  async (request) => {
    // --------------------------------------------------
    // 1. Kontrollera Firebase Authentication
    // --------------------------------------------------
    const uid = request.auth ? request.auth.uid : null;

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated.");
    }

    // --------------------------------------------------
    // 2. Läs data från Flutter
    // --------------------------------------------------

    const data = request.data || {};

    const productId = data.productId;
    const purchaseToken = data.verificationData;
    const purchaseId = data.purchaseId;
    const source = data.source;

    console.log("=== VERIFY PURCHASE ===");
    console.log("uid:", uid);
    console.log("productId:", productId);
    console.log("purchaseId:", purchaseId);
    console.log("source:", source);

    const {google} = require("googleapis");
    if (!productId || !purchaseToken) {
      throw new HttpsError(
        "invalid-argument",
        "Missing productId or purchase token.",
      );
    }

    // --------------------------------------------------
    // 3. Kontrollera rätt produkt
    // --------------------------------------------------

    if (productId !== PRODUCT_ID) {
      throw new HttpsError("invalid-argument", "Invalid productId.");
    }

    try {
      // ------------------------------------------------
      // 4. Autentisera mot Google Play Developer API
      // ------------------------------------------------
      console.log("---------------KOLLAr AUTH------------------");
      const auth = new google.auth.GoogleAuth({
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });

      const client = await auth.getClient();

      console.log("Auth client type:", client.constructor.name);
      console.log("Project ID:", await auth.getProjectId());
      console.log("Google auth email:", client.email);

      const credentials = await auth.getCredentials();

      console.log("Google credentials:", {
        client_email: credentials.client_email,
        project_id: credentials.project_id,
      });

      const accessToken = await client.getAccessToken();

      console.log("Access token available:", !!accessToken.token);

      const androidPublisher = google.androidpublisher({
        version: "v3",
        auth,
      });

      // ------------------------------------------------
      // 5. Hämta köpet från Google Play
      // ------------------------------------------------

      const response = await androidPublisher.purchases.products.get({
        packageName: PACKAGE_NAME,
        productId: PRODUCT_ID,
        token: purchaseToken,
      });

      const purchase = response.data;

      console.log("Google Play purchase:", {
        productId: productId,
        purchaseState: purchase.purchaseState,
        acknowledgementState: purchase.acknowledgementState,
        consumptionState: purchase.consumptionState,
        orderId: purchase.orderId,
        purchaseTimeMillis: purchase.purchaseTimeMillis,
      });

      // ------------------------------------------------
      // 6. Kontrollera purchaseState
      //
      // 0 = purchased
      // 1 = canceled
      // 2 = pending
      // ------------------------------------------------

      if (purchase.purchaseState !== 0) {
        console.log(
          "Purchase not completed. purchaseState:",
          purchase.purchaseState,
        );

        return {
          success: false,
          valid: false,
          message: "Purchase is not completed.",
          purchaseState: purchase.purchaseState,
        };
      }

      // ------------------------------------------------
      // 7. Skriv Premium-status till Firestore
      // ------------------------------------------------
      console.log("ABOUT TO WRITE FIRESTORE");
      console.log("Firestore path: users/" + uid);
      await db.collection("users").doc(uid).set(
        {
          premium: true,
          productId: PRODUCT_ID,
          purchaseToken: purchaseToken,
          updatedAt: new Date(),
        },
        { merge: true },
      );

      console.log("Premium enabled for user:", uid);

      // ------------------------------------------------
      // 8. Returnera lyckat resultat
      // ------------------------------------------------

      return {
        success: true,
        valid: true,
        message: "Purchase verified.",
      };
    } catch (error) {
      console.error("verifyPurchase failed:", error);

      throw new HttpsError("internal", "Purchase verification failed.");
    }
  },
);
