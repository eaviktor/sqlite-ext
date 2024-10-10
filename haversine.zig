const std = @import("std");
const c = @cImport(@cInclude("sqlite3ext.h"));

const earth_radius = 6371.0;
pub var sqlite3_api: [*c]c.sqlite3_api_routines = null;
fn toRadians(deg: f64) f64 {
    return deg * (std.math.pi / 180.0);
}

//SELECT haversine(52.5200, 13.4050, 48.8566, 2.3522) AS distance;
fn haversine(lat1: f64, lon1: f64, lat2: f64, lon2: f64) f64 {
    const dlat = toRadians(lat2 - lat1);
    const dlon = toRadians(lon2 - lon1);

    const a = std.math.sin(dlat / 2) * std.math.sin(dlat / 2) +
        std.math.cos(toRadians(lat1)) *
        std.math.cos(toRadians(lat2)) *
        std.math.sin(dlon / 2) * std.math.sin(dlon / 2);

    return earth_radius * 2 * std.math.atan2(std.math.sqrt(a), std.math.sqrt(1 - a));
}

fn haversineSqlite(ctx: ?*c.sqlite3_context, argc: c_int, argv: [*c]?*c.sqlite3_value) callconv(.C) void {
    if (argc != 4) {
        std.log.debug("Wrong amount of arguments {?}", .{argc});
        c.sqlite3_result_null(ctx);
        return;
    }

    const lat1 = c.sqlite3_value_double(argv[0]);
    const lon1 = c.sqlite3_value_double(argv[1]);
    const lat2 = c.sqlite3_value_double(argv[2]);
    const lon2 = c.sqlite3_value_double(argv[3]);

    const distance = haversine(lat1, lon1, lat2, lon2);
    c.sqlite3_result_double(ctx, distance);
}

pub export fn sqlite3_extension_init(db: ?*c.sqlite3, pzErrMsg: ?*?*u8, pApi: ?*c.sqlite3_api_routines) c_int {
    sqlite3_api = pApi.?;

    const rc = sqlite3_api.*.create_function_v2.?(db, "haversine", 4, c.SQLITE_UTF8, null, haversineSqlite, null, null, null);

    if (rc != c.SQLITE_OK) {
        std.log.debug("Error while doing stuff error code {?}", .{rc});

        if (pzErrMsg != null) {
            std.log.debug("Error Message - {?}", .{pzErrMsg});
        }
    }

    return rc;
}
