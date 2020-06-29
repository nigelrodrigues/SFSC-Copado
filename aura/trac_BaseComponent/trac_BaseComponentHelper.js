/**
 * Created by gtorres on 6/25/2020.
 */

({
    isValidResponse: function (res) {
        return res != null && (res == 200 || res == 201 || res == 204);
    },

    handlMerkleError: function(cmp, error, reattemptMethod, response) {
        if(error.isMerkleError) {
            var statusCode = error.statusCode;
            var canRetry = !(statusCode && this.isValidResponse(statusCode));
            var bodyMsg = canRetry ? error.str : error.message;
            var responseCode = canRetry ? statusCode : error.code;
            cmp.getEvent('trac_MerkleErrorEvent')
                .setParams({
                    'canRetry': canRetry,
                    'reattempt': reattemptMethod,
                    'bodyMsg': bodyMsg,
                    'responseCode': responseCode
                })
                .fire();
        } else {
            cmp.set("v.isError", true);
            cmp.set("v.errorMsg", error);

        }
    },

    isMerkleErrorHandled: function(cmp, reattemptMethod, response) {
        var state = response.getState();
        if ( !cmp.isValid() || state !== "SUCCESS") {
            this.handlMerkleError(cmp, new Error(response.getError()[0].message));
            return true;
        }

        var result = response.getReturnValue();

        if (typeof result === undefined || result == null) {
            this.handlMerkleError(cmp, new Error('Connection Error'));
            return true;
        }

        var success = result.isSuccess && result.returnValuesMap['body']['success'];
        var invalidForm = result.returnValuesMap['validForm'] != null && !result.returnValuesMap['validForm'];

        if(success || invalidForm) {
            //successful execution or invalid form error (both cases mean no merkle error has occurred)
            return false;
        }
        else {
            var statusCode = result.returnValuesMap['statusCode'];
            var error = new Error(response.getError());
            var str = result.returnValuesMap['body'];
            error.isMerkleError = true;
            error.statusCode = statusCode;
            if (this.isValidResponse(statusCode))  {
                var body = JSON.parse(str);
                error.code = body.data.code;
                error.message = body.data.message;
            }
            else {
                error.str = str;
            }
            this.handlMerkleError(cmp, error, reattemptMethod);
            return true;
        }
    }
});