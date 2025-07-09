package com.appnox.iospedometer;

import android.util.Log;

public class PedometerPlugin {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
