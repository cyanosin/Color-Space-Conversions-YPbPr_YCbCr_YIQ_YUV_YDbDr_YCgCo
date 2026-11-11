/*
    -- Primary References --
    https://www.itu.int/rec/T-REC-H.273-202407-I/en
    https://pub.smpte.org/doc/rp177/19931101-pub/
    https://dn710804.ca.archive.org/0/items/gov.law.cie.15.2004/cie.15.2004.pdf

    -- Secondary References --
    https://www.govinfo.gov/content/pkg/CFR-2013-title47-vol4/pdf/CFR-2013-title47-vol4-sec73-682.pdf
    https://www.itu.int/rec/R-REC-BT.1700-0-200502-I/en
    https://pub.smpte.org/doc/rp145/20041108-pub/
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2020-2-201510-I!!PDF-E.pdf
*/

/*
    --- Chromaticity Coordinates ---

      | -- NTSC 1953 ------- | -- PAL / SECAM ------- | -- SMPTE C ----------- | -- BT.709 / sRGB ----- | -- BT.2020 ----------- |
    R | x = 0.67,  y = 0.33  | x = 0.64,   y = 0.33   | x = 0.630,  y = 0.340  | x = 0.640,  y = 0.330  | x = 0.708,  y = 0.292  |
    G | x = 0.21,  y = 0.71  | x = 0.29,   y = 0.60   | x = 0.310,  y = 0.595  | x = 0.300,  y = 0.600  | x = 0.170,  y = 0.797  |
    B | x = 0.14,  y = 0.08  | x = 0.15,   y = 0.06   | x = 0.155,  y = 0.070  | x = 0.150,  y = 0.060  | x = 0.131,  y = 0.046  |
    W | x = 0.310, y = 0.316 | x = 0.3127, y = 0.3290 | x = 0.3127, y = 0.3290 | x = 0.3127, y = 0.3290 | x = 0.3127, y = 0.3290 |
*/

#define xyR vec2(0.640,  0.330)
#define xyG vec2(0.300,  0.600)
#define xyB vec2(0.150,  0.060)
#define xyW vec2(0.3127, 0.3290)

#define XYZ_WHITE vec3(xyW.x / xyW.y, 1.0, (1.0 - xyW.x - xyW.y) / xyW.y)

vec3 RGB_to_XYZ(vec3 RGB)
{
    const vec3 R = vec3(xyR, 1.0 - xyR.x - xyR.y);
    const vec3 G = vec3(xyG, 1.0 - xyG.x - xyG.y);
    const vec3 B = vec3(xyB, 1.0 - xyB.x - xyB.y);

    const mat3 P = mat3(R, G, B);

    const vec3 C = inverse(P) * XYZ_WHITE;

    const mat3 M = P * mat3(
        C.x, 0.0, 0.0,
        0.0, C.y, 0.0,
        0.0, 0.0, C.z
    );

    return M * RGB;
}

vec3 XYZ_to_RGB(vec3 XYZ)
{
    const vec3 R = vec3(xyR, 1.0 - xyR.x - xyR.y);
    const vec3 G = vec3(xyG, 1.0 - xyG.x - xyG.y);
    const vec3 B = vec3(xyB, 1.0 - xyB.x - xyB.y);

    const mat3 P = mat3(R, G, B);

    const vec3 C = inverse(P) * XYZ_WHITE;

    const mat3 M = P * mat3(
        C.x, 0.0, 0.0,
        0.0, C.y, 0.0,
        0.0, 0.0, C.z
    );

    return inverse(M) * XYZ;
}

vec3 Lab_f(vec3 t)
{
    return mix(
        pow(max(t, vec3(0.0)), vec3(1.0 / 3.0)),
        (841.0 / 108.0) * t + (16.0 / 116.0),
        lessThanEqual(t, vec3(216.0 / 24389.0))
    );
}

vec3 Lab_inverse_f(vec3 t)
{
    return mix(
        t * t * t,
        (108.0 / 841.0) * (t - 16.0 / 116.0),
        lessThanEqual(t, vec3(24.0 / 116.0))
    );
}

vec3 XYZ_to_Lab(vec3 XYZ)
{
    const vec3 f = Lab_f(XYZ / XYZ_WHITE);

    return vec3(
        116.0 * f.y - 16.0,
        500.0 * (f.x - f.y),
        200.0 * (f.y - f.z)
    );
}

vec3 Lab_to_XYZ(vec3 Lab)
{
    const float fy = (Lab.x + 16.0) / 116.0;

    const vec3 f = vec3(fy + Lab.y / 500.0, fy, fy - Lab.z / 200.0);

    return Lab_inverse_f(f) * XYZ_WHITE;
}

vec3 RGB_to_Lab(vec3 RGB)
{
    return XYZ_to_Lab(RGB_to_XYZ(RGB));
}

vec3 Lab_to_RGB(vec3 Lab)
{
    return XYZ_to_RGB(Lab_to_XYZ(Lab));
}

vec2 XYZ_to_uvPrime(vec3 XYZ)
{
    const float d = XYZ.x + 15.0 * XYZ.y + 3.0 * XYZ.z;

    if (d == 0.0) return vec2(0.0);

    return vec2(4.0 * XYZ.x, 9.0 * XYZ.y) / d;
}

vec3 XYZ_to_Luv(vec3 XYZ)
{
    const float L = 116.0 * Lab_f(XYZ / XYZ_WHITE).y - 16.0;

    const vec2 uv = XYZ_to_uvPrime(XYZ);
    const vec2 uvWhite = XYZ_to_uvPrime(XYZ_WHITE);

    return vec3(L, 13.0 * L * (uv - uvWhite));
}

vec3 Luv_to_XYZ(vec3 Luv)
{
    if (Luv.x == 0.0) return vec3(0.0);

    const float fy = (Luv.x + 16.0) / 116.0;

    const float Y = Lab_inverse_f(vec3(fy)).x * XYZ_WHITE.y;
    const vec2 uv = Luv.yz / (13.0 * Luv.x) + XYZ_to_uvPrime(XYZ_WHITE);

    return vec3(
        9.0 * Y * uv.x / (4.0 * uv.y),
        Y,
        Y * (12.0 - 3.0 * uv.x - 20.0 * uv.y) / (4.0 * uv.y)
    );
}

vec3 RGB_to_Luv(vec3 RGB)
{
    return XYZ_to_Luv(RGB_to_XYZ(RGB));
}

vec3 Luv_to_RGB(vec3 Luv)
{
    return XYZ_to_RGB(Luv_to_XYZ(Luv));
}
