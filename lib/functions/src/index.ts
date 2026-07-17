import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import * as admin from "firebase-admin";

import { google } from "googleapis";

admin.initializeApp();

const db = admin.firestore();

const PACKAGE_NAME = "se.asgoit.phloura";
const PRODUCT_ID = "ploura_pro";

const auth = new google.auth.GoogleAuth({
    scopes: [
        "https://www.googleapis.com/auth/androidpublisher"
    ]
});

const androidPublisher = google.androidpublisher({
    version: "v3",
    auth
});

interface VerifyRequest {
    uid: string;
    productId: string;
    purchaseId?: string;
    verificationData: string;
    source: string;
}


async function verifyAndroidPurchase(
    purchaseToken: string,
    productId: string
): Promise<boolean> {

    const response =
        await androidPublisher.purchases.products.get({

            packageName: PACKAGE_NAME,

            productId: productId,

            token: purchaseToken
        });

    const purchase = response.data;

    if (!purchase) {
        return false;
    }

    if (purchase.purchaseState !== 0) {
        return false;
    }

    if (purchase.consumptionState !== 0) {
        return false;
    }

    return true;
}


async function setPremium(
    uid: string,
    premium: boolean
) {

    await db.collection("users")
        .doc(uid)
        .set({

            premium,

            productId: PRODUCT_ID,

            updatedAt:
                admin.firestore.FieldValue.serverTimestamp()

        }, { merge: true });

}

export const verifyPurchase =
    onCall(async (request) => {

        const data =
            request.data as VerifyRequest;

        if (!data.uid) {
            throw new HttpsError(
                "invalid-argument",
                "uid missing"
            );
        }

        if (data.productId != PRODUCT_ID) {

            return {
                valid: false
            };
        }

        logger.info(
            "Verifying purchase...",
            data.uid
        );

                try {

            let valid = false;

            if (data.source.toLowerCase().contains("google")) {

                valid = await verifyAndroidPurchase(
                    data.verificationData,
                    data.productId
                );

            } else if (data.source.toLowerCase().contains("app_store")) {

                valid = await verifyIOSPurchase(
                    data.verificationData,
                    data.productId
                );

            } else {

                throw new HttpsError(
                    "invalid-argument",
                    "Unknown purchase source"
                );

            }

            if (valid) {

                await setPremium(data.uid, true);

                return {
                    valid: true
                };
            }

            await setPremium(data.uid, false);

            return {
                valid: false
            };

        } catch (e) {

            logger.error(e);

            throw new HttpsError(
                "internal",
                "Purchase verification failed"
            );
        }

    });

    async function verifyIOSPurchase(
    verificationData: string,
    productId: string
): Promise<boolean> {

    // Apple verification goes here.

    // Verify the signed transaction with the
    // App Store Server API.

    // Check that:
    // • transaction is valid
    // • bundle ID matches
    // • productId == ploura_pro
    // • purchase is not revoked

    return true;
}


