/**
 *  @description Utilities for Date processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public with sharing class TLDate {

    /**
     *  @description Format a Date into a text string using the Datetime format functionality
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static String formatDate(Date d, String format) {
        String formattedDate;

        if (d != null) {
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            formattedDate = dt.format(format);
        }

        return formattedDate;
    }

    /**
     *  @description Get the Date from a Datetime
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static Date convertDatetimeToDate(DateTime dt) {
        Date convertedDate;

        if (dt != null) {
            convertedDate = Date.newInstance(dt.year(), dt.month(), dt.day());
        }

        return convertedDate;
    }




}