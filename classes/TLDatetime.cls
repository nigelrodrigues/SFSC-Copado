/**
 *  @description Utilities for Datetime processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLDatetime {

    /**
     *  @description Format a DateTime as UTC format (ex: 2018-10-30T17:53:00Z)
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static String formatDatetimeUTC(DateTime dt) {
        String formattedDateTime;

        if (dt != null) {
            formattedDateTime = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        return formattedDateTime;
    }

    public static Decimal getTimeBetweenDatetimesInMilliseconds(Datetime startDatetime, Datetime endDatetime) {
        Decimal timeInMilliseconds;

        if (startDatetime != null && endDatetime != null) {
            timeInMilliseconds = endDatetime.getTime() - startDatetime.getTime();
        }

        return timeInMilliseconds;
    }

    public static Decimal getTimeBetweenDatetimesInSeconds(Datetime startDatetime, Datetime endDatetime) {
        Decimal timeInSeconds;

        if (startDatetime != null && endDatetime != null) {
            timeInSeconds = getTimeBetweenDatetimesInMilliseconds(startDatetime, endDatetime) / 1000;
        }

        return timeInSeconds;
    }

    public static Decimal getTimeBetweenDatetimesInMinutes(Datetime startDatetime, Datetime endDatetime) {
        Decimal timeInMinutes;

        if (startDatetime != null && endDatetime != null) {
            timeInMinutes = getTimeBetweenDatetimesInSeconds(startDatetime, endDatetime) / 60;
        }

        return timeInMinutes;
    }

    public static Decimal getTimeBetweenDatetimesInHours(Datetime startDatetime, Datetime endDatetime) {
        Decimal timeInHours;

        if (startDatetime != null && endDatetime != null) {
            timeInHours = getTimeBetweenDatetimesInMinutes(startDatetime, endDatetime) / 60;
        }

        return timeInHours;
    }

    public static Decimal getTimeBetweenDatetimesInDays(Datetime startDatetime, Datetime endDatetime) {
        Decimal timeInDays;

        if (startDatetime != null && endDatetime != null) {
            timeInDays = getTimeBetweenDatetimesInHours(startDatetime, endDatetime) / 24;
        }

        return timeInDays;
    }
}