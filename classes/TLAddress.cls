/**
 *  @description Utilities for Address processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLAddress {

    /**
     *  @description String Utility Method to extract a Street Number from an address string
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        6/7/2018
     */
    public static String getNumberFromAddressString(String address) {
        String addressNumber;

        if (address != null) {
            List<String> addressStrings = address.split(' ');
            addressNumber = addressStrings[0];
        }

        return addressNumber;
    }

    /**
     *  @description String Utility Method to extract a Street Name from an address string
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        6/7/2018
     */
    public static String getStreetNameFromAddressString(String address) {
        String streetName = address;

        if (address != null) {
            List<String> addressStrings = address.split(' ');
            if (addressStrings.size() > 1) {
                streetName = streetName.removeStart(addressStrings[0]);
            }
            //changed from .isAlpha to .isNumeric since it was not taking ' or -
            if (addressStrings[addressStrings.size() - 1].isNumeric() || addressStrings[addressStrings.size() - 1].containsAny('#,')) {
                streetName = streetName.removeEnd(addressStrings[addressStrings.size() - 1]);
            }

            streetName = streetName.removeStart(' ').removeEnd(' ');

            streetName = (streetName.length() > 0) ? streetName : address;
        }

        return streetName;
    }

    /**
     *  @description String Utility Method to extract a Suite Number from an address string
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        6/7/2018
     */
    public static String getSuiteNumberFromAddressString(String address) {
        String suite = '';

        if (address != null) {
            for (Integer i = (address.length() - 1); i >= 0; i--) {
                if (address.substring(i, i + 1).isNumeric()) {
                    suite = address.substring(i, i + 1) + suite;
                }
                else {
                    break;
                }
            }
        }

        return (suite.length() > 0) ? suite : null;
    }

    /**
     *  @description Format a Postal Code into A1A 1A1 or Zip Format
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2/1/2018
     */
    public static String getFormattedPostalCode(String postalCode) {

        String formattedPostalCode = postalCode;

        if (isCanadianPostalCode(postalCode)) {
            if (postalCode.length() == 6) { //Has no Space
                formattedPostalCode = postalCode.left(3).toUpperCase() + ' ' + postalCode.right(3).toUpperCase();
            }
            else if (postalCode.length() == 7) { // Has a Space
                formattedPostalCode = postalCode.toUpperCase();
            }
        }

        return formattedPostalCode;
    }

    /**
     *  @description Returns true if the postal code is in a A1A1A1 or a1a 1a1 format or anything between
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2/1/2018
     */
    public static Boolean isCanadianPostalCode(String postalCode) {
        Boolean isCanadianPostalCode = false;

        String regexString = '^[A-Za-z]{1}\\d{1}[A-Za-z]{1} *\\d{1}[A-Za-z]{1}\\d{1}$';

        if (postalCode != null && Pattern.matches(regexString, postalCode)) {
            isCanadianPostalCode = true;
        }

        return isCanadianPostalCode;
    }
}