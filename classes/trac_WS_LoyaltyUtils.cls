/**
 * @description Utility class for Loyalty (Merkle) web services
 * @author Bryan Cantos (HBC), Alex Kong (ToD)
 * @date 2020-05-27
 */

public with sharing class trac_WS_LoyaltyUtils {

    public static String generateHash(String secretKey, Map<String,String> params) {

        String sig = secretKey;

        List<String> sortedKeys = new List<String>(params.keySet());
        sortedKeys.sort();

        for (String key : sortedKeys) {
            sig += key + params.get(key);
        }

        System.debug('sig before hash: ' + sig);
        Blob requestBlob = Blob.valueOf(sig);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        String hashedSig = EncodingUtil.convertToHex(hash);
        System.debug('hashed sig: ' + hashedSig);

        return hashedSig;
    }
}