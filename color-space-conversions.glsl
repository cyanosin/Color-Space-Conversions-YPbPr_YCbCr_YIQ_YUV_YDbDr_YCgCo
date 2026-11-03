/*
    https://www.itu.int/rec/T-REC-H.273-202407-I/en
    https://pub.smpte.org/doc/st170/20041130-pub/st0170-2004_stable2010.pdf
    https://www.itu.int/rec/R-REC-BT.470-6-199811-S/en
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

vec3 RGB_to_YPbPr(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    return vec3(Y, Pb, Pr);
}

vec3 YPbPr_to_RGB(vec3 ypp)
{
    const float Y  = ypp.x;
    const float Pb = ypp.y;
    const float Pr = ypp.z;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr_UNORM(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    const float Yd = round(219.0 * Y  +  16.0);
    const float Cb = round(224.0 * Pb + 128.0);
    const float Cr = round(224.0 * Pr + 128.0);

    return vec3(Yd, Cb, Cr) / 255.0;
}

vec3 YCbCr_UNORM_to_RGB(vec3 ycc)
{
    const float Y  = (255.0 * ycc.x -  16.0) / 219.0;
    const float Pb = (255.0 * ycc.y - 128.0) / 224.0;
    const float Pr = (255.0 * ycc.z - 128.0) / 224.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

uvec3 RGB_to_YCbCr_UINT(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    const uint Yd = uint(round(219.0 * Y  +  16.0));
    const uint Cb = uint(round(224.0 * Pb + 128.0));
    const uint Cr = uint(round(224.0 * Pr + 128.0));

    return uvec3(Yd, Cb, Cr);
}

vec3 YCbCr_UINT_to_RGB(uvec3 ycc)
{
    const float Y  = (float(ycc.x) -  16.0) / 219.0;
    const float Pb = (float(ycc.y) - 128.0) / 224.0;
    const float Pr = (float(ycc.z) - 128.0) / 224.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr_FR_UNORM(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    const float Yd = clamp(round(255.0 * Y),          0.0, 255.0);
    const float Cb = clamp(round(255.0 * Pb + 128.0), 0.0, 255.0);
    const float Cr = clamp(round(255.0 * Pr + 128.0), 0.0, 255.0);

    return vec3(Yd, Cb, Cr) / 255.0;
}

vec3 YCbCr_FR_UNORM_to_RGB(vec3 ycc)
{
    const float Y  = ycc.x;
    const float Pb = (255.0 * ycc.y - 128.0) / 255.0;
    const float Pr = (255.0 * ycc.z - 128.0) / 255.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

uvec3 RGB_to_YCbCr_FR_UINT(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    const float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    const uint Yd = uint(clamp(round(255.0 * Y),          0.0, 255.0));
    const uint Cb = uint(clamp(round(255.0 * Pb + 128.0), 0.0, 255.0));
    const uint Cr = uint(clamp(round(255.0 * Pr + 128.0), 0.0, 255.0));

    return uvec3(Yd, Cb, Cr);
}

vec3 YCbCr_FR_UINT_to_RGB(uvec3 ycc)
{
    const float Y  =  float(ycc.x)          / 255.0;
    const float Pb = (float(ycc.y) - 128.0) / 255.0;
    const float Pr = (float(ycc.z) - 128.0) / 255.0;

    const float R = Y + 2.0 * (1.0 - Kr) * Pr;
    const float B = Y + 2.0 * (1.0 - Kb) * Pb;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YIQ(vec3 rgb)
{
    const float Y = dot(rgb, vec3(Kr, Kg, Kb));
    const float U = 0.492111 * (rgb.b - Y);
    const float V = 0.877283 * (rgb.r - Y);

    const float I = -U * sin(radians(33.0))
                  +  V * cos(radians(33.0));

    const float Q =  U * cos(radians(33.0))
                  +  V * sin(radians(33.0));

    return vec3(Y, I, Q);
}

vec3 YIQ_to_RGB(vec3 yiq)
{
    const float Y = yiq.x;
    const float I = yiq.y;
    const float Q = yiq.z;

    const float U = -I * sin(radians(33.0))
                  +  Q * cos(radians(33.0));

    const float V =  I * cos(radians(33.0))
                  +  Q * sin(radians(33.0));

    const float R = Y + V / 0.877283;
    const float B = Y + U / 0.492111;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YUV(vec3 rgb)
{
    const float Y = dot(rgb, vec3(Kr, Kg, Kb));
    const float U = 0.492111 * (rgb.b - Y);
    const float V = 0.877283 * (rgb.r - Y);

    return vec3(Y, U, V);
}

vec3 YUV_to_RGB(vec3 yuv)
{
    const float Y = yuv.x;
    const float U = yuv.y;
    const float V = yuv.z;

    const float R = Y + V / 0.877283;
    const float B = Y + U / 0.492111;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YDbDr(vec3 rgb)
{
    const float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    const float Db =  1.505 * (rgb.b - Y);
    const float Dr = -1.902 * (rgb.r - Y);

    return vec3(Y, Db, Dr);
}

vec3 YDbDr_to_RGB(vec3 ydd)
{
    const float Y  = ydd.x;
    const float Db = ydd.y;
    const float Dr = ydd.z;

    const float R = Y + Dr / -1.902;
    const float B = Y + Db /  1.505;
    const float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCgCo(vec3 rgb)
{
    const float Y  = 0.5 * rgb.g + 0.25 * (rgb.r + rgb.b);
    const float Cg = 0.5 * rgb.g - 0.25 * (rgb.r + rgb.b);
    const float Co = 0.5 * (rgb.r - rgb.b);

    return vec3(Y, Cg, Co);
}

vec3 YCgCo_to_RGB(vec3 ycc)
{
    const float Y  = ycc.x;
    const float Cg = ycc.y;
    const float Co = ycc.z;

    const float R = Y - Cg + Co;
    const float G = Y + Cg;
    const float B = Y - Cg - Co;

    return vec3(R, G, B);
}
