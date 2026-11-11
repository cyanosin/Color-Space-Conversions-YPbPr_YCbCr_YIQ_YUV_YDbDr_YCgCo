/*
    -- Primary References --
    https://www.itu.int/rec/T-REC-H.273-202407-I/en
    https://pub.smpte.org/doc/st170/20041130-pub/
    https://www.itu.int/rec/R-REC-BT.1700-0-200502-I/en

    -- Secondary References --
    https://www.govinfo.gov/content/pkg/CFR-2013-title47-vol4/pdf/CFR-2013-title47-vol4-sec73-682.pdf
    https://www.itu.int/rec/R-REC-BT.470-6-199811-S/en
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.601-7-201103-I!!PDF-E.pdf
    https://pub.smpte.org/doc/st240/19991111-pub/
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2020-2-201510-I!!PDF-E.pdf
*/

/*
    -- Matrix Coefficients --

    FCC 1953:   Kr = 0.30,   Kb = 0.11
    BT.470/601: Kr = 0.299,  Kb = 0.114
    SMPTE 240M: Kr = 0.212,  Kb = 0.087
    BT.709:     Kr = 0.2126, Kb = 0.0722
    BT.2020:    Kr = 0.2627, Kb = 0.0593

    Kg = 1.0 - Kb - Kr
*/

#define Kr 0.2126
#define Kg (1.0 - Kb - Kr)
#define Kb 0.0722

vec3 RGB_to_YPbPr(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Pb = (RGB.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (RGB.r - Y) / (2.0 * (1.0 - Kr));

    return vec3(Y, Pb, Pr);
}

vec3 YPbPr_to_RGB(vec3 YPP)
{
    const float Y  = YPP.x;
    const float Pb = YPP.y;
    const float Pr = YPP.z;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr_UNORM(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Pb = (RGB.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (RGB.r - Y) / (2.0 * (1.0 - Kr));

    const float Yd = round(219.0 * Y  +  16.0);
    const float Cb = round(224.0 * Pb + 128.0);
    const float Cr = round(224.0 * Pr + 128.0);

    return vec3(Yd, Cb, Cr) / 255.0;
}

vec3 YCbCr_UNORM_to_RGB(vec3 YCC)
{
    const float Y  = (255.0 * YCC.x -  16.0) / 219.0;
    const float Pb = (255.0 * YCC.y - 128.0) / 224.0;
    const float Pr = (255.0 * YCC.z - 128.0) / 224.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

uvec3 RGB_to_YCbCr_UINT(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Pb = (RGB.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (RGB.r - Y) / (2.0 * (1.0 - Kr));

    const uint Yd = uint(round(219.0 * Y  +  16.0));
    const uint Cb = uint(round(224.0 * Pb + 128.0));
    const uint Cr = uint(round(224.0 * Pr + 128.0));

    return uvec3(Yd, Cb, Cr);
}

vec3 YCbCr_UINT_to_RGB(uvec3 YCC)
{
    const float Y  = (float(YCC.x) -  16.0) / 219.0;
    const float Pb = (float(YCC.y) - 128.0) / 224.0;
    const float Pr = (float(YCC.z) - 128.0) / 224.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr_FR_UNORM(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Pb = (RGB.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (RGB.r - Y) / (2.0 * (1.0 - Kr));

    const float Yd = clamp(round(255.0 * Y),          0.0, 255.0);
    const float Cb = clamp(round(255.0 * Pb + 128.0), 0.0, 255.0);
    const float Cr = clamp(round(255.0 * Pr + 128.0), 0.0, 255.0);

    return vec3(Yd, Cb, Cr) / 255.0;
}

vec3 YCbCr_FR_UNORM_to_RGB(vec3 YCC)
{
    const float Y  = YCC.x;
    const float Pb = (255.0 * YCC.y - 128.0) / 255.0;
    const float Pr = (255.0 * YCC.z - 128.0) / 255.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

uvec3 RGB_to_YCbCr_FR_UINT(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Pb = (RGB.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (RGB.r - Y) / (2.0 * (1.0 - Kr));

    const uint Yd = uint(clamp(round(255.0 * Y),          0.0, 255.0));
    const uint Cb = uint(clamp(round(255.0 * Pb + 128.0), 0.0, 255.0));
    const uint Cr = uint(clamp(round(255.0 * Pr + 128.0), 0.0, 255.0));

    return uvec3(Yd, Cb, Cr);
}

vec3 YCbCr_FR_UINT_to_RGB(uvec3 YCC)
{
    const float Y  =  float(YCC.x)          / 255.0;
    const float Pb = (float(YCC.y) - 128.0) / 255.0;
    const float Pr = (float(YCC.z) - 128.0) / 255.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YIQ(vec3 RGB)
{
    const float Y = dot(RGB, vec3(Kr, Kg, Kb));
    const float U = 0.492111 * (RGB.b - Y);
    const float V = 0.877283 * (RGB.r - Y);

    const float I = -U * sin(radians(33.0))
                  +  V * cos(radians(33.0));

    const float Q =  U * cos(radians(33.0))
                  +  V * sin(radians(33.0));

    return vec3(Y, I, Q);
}

vec3 YIQ_to_RGB(vec3 YIQ)
{
    const float Y = YIQ.x;
    const float I = YIQ.y;
    const float Q = YIQ.z;

    const float U = -I * sin(radians(33.0))
                  +  Q * cos(radians(33.0));

    const float V =  I * cos(radians(33.0))
                  +  Q * sin(radians(33.0));

    const float R = Y + V / 0.877283;
    const float B = Y + U / 0.492111;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YUV(vec3 RGB)
{
    const float Y = dot(RGB, vec3(Kr, Kg, Kb));
    const float U = 0.492111 * (RGB.b - Y);
    const float V = 0.877283 * (RGB.r - Y);

    return vec3(Y, U, V);
}

vec3 YUV_to_RGB(vec3 YUV)
{
    const float Y = YUV.x;
    const float U = YUV.y;
    const float V = YUV.z;

    const float R = Y + V / 0.877283;
    const float B = Y + U / 0.492111;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YDbDr(vec3 RGB)
{
    const float Y  = dot(RGB, vec3(Kr, Kg, Kb));
    const float Db =  1.505 * (RGB.b - Y);
    const float Dr = -1.902 * (RGB.r - Y);

    return vec3(Y, Db, Dr);
}

vec3 YDbDr_to_RGB(vec3 YDD)
{
    const float Y  = YDD.x;
    const float Db = YDD.y;
    const float Dr = YDD.z;

    const float R = Y + Dr / -1.902;
    const float B = Y + Db /  1.505;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCgCo(vec3 RGB)
{
    const float Y  = 0.5 * RGB.g + 0.25 * (RGB.r + RGB.b);
    const float Cg = 0.5 * RGB.g - 0.25 * (RGB.r + RGB.b);
    const float Co = 0.5 * (RGB.r - RGB.b);

    return vec3(Y, Cg, Co);
}

vec3 YCgCo_to_RGB(vec3 YCC)
{
    const float Y  = YCC.x;
    const float Cg = YCC.y;
    const float Co = YCC.z;

    const float R = Y - Cg + Co;
    const float G = Y + Cg;
    const float B = Y - Cg - Co;

    return vec3(R, G, B);
}
