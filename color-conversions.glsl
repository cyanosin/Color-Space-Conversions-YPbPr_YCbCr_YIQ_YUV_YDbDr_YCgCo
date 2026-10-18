/*
    https://www.itu.int/rec/T-REC-H.273
    https://pub.smpte.org/doc/st170/20041130-pub/st0170-2004_stable2010.pdf
    https://www.itu.int/rec/r-rec-bt.470/en
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
    float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    return vec3(Y, Pb, Pr);
}

vec3 YPbPr_to_RGB(vec3 ypp)
{
    float Y  = ypp.x;
    float Pb = ypp.y;
    float Pr = ypp.z;

    float R = Y + 2.0 * (1.0 - Kr) * Pr;
    float B = Y + 2.0 * (1.0 - Kb) * Pb;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr(vec3 rgb)
{
    float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    Y        = round(219.0 * Y  +  16.0);
    float Cb = round(224.0 * Pb + 128.0);
    float Cr = round(224.0 * Pr + 128.0);

    return vec3(Y, Cb, Cr) / 255.0;
}

vec3 YCbCr_to_RGB(vec3 ycc)
{
    float Y  = (255.0 * ycc.x -  16.0) / 219.0;
    float Pb = (255.0 * ycc.y - 128.0) / 224.0;
    float Pr = (255.0 * ycc.z - 128.0) / 224.0;

    float R = Y + 2.0 * (1.0 - Kr) * Pr;
    float B = Y + 2.0 * (1.0 - Kb) * Pb;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCbCr_FR(vec3 rgb)
{
    float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    float Pb = (rgb.b - Y) / (2.0 * (1.0 - Kb));
    float Pr = (rgb.r - Y) / (2.0 * (1.0 - Kr));

    Y        = clamp(round(255.0 * Y),          0.0, 255.0);
    float Cb = clamp(round(255.0 * Pb + 128.0), 0.0, 255.0);
    float Cr = clamp(round(255.0 * Pr + 128.0), 0.0, 255.0);

    return vec3(Y, Cb, Cr) / 255.0;
}

vec3 YCbCr_FR_to_RGB(vec3 ycc)
{
    float Y  = ycc.x;
    float Pb = (255.0 * ycc.y - 128.0) / 255.0;
    float Pr = (255.0 * ycc.z - 128.0) / 255.0;

    float R = Y + 2.0 * (1.0 - Kr) * Pr;
    float B = Y + 2.0 * (1.0 - Kb) * Pb;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YIQ(vec3 rgb)
{
    float Y = dot(rgb, vec3(Kr, Kg, Kb));
    float U = 0.492111 * (rgb.b - Y);
    float V = 0.877283 * (rgb.r - Y);

    float I = -U * sin(radians(33.0))
            +  V * cos(radians(33.0));

    float Q =  U * cos(radians(33.0))
            +  V * sin(radians(33.0));

    return vec3(Y, I, Q);
}

vec3 YIQ_to_RGB(vec3 yiq)
{
    float Y = yiq.x;
    float I = yiq.y;
    float Q = yiq.z;

    float U = -I * sin(radians(33.0))
            +  Q * cos(radians(33.0));

    float V =  I * cos(radians(33.0))
            +  Q * sin(radians(33.0));

    float R = Y + V / 0.877283;
    float B = Y + U / 0.492111;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YUV(vec3 rgb)
{
    float Y = dot(rgb, vec3(Kr, Kg, Kb));
    float U = 0.492111 * (rgb.b - Y);
    float V = 0.877283 * (rgb.r - Y);

    return vec3(Y, U, V);
}

vec3 YUV_to_RGB(vec3 yuv)
{
    float Y = yuv.x;
    float U = yuv.y;
    float V = yuv.z;

    float R = Y + V / 0.877283;
    float B = Y + U / 0.492111;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YDbDr(vec3 rgb)
{
    float Y  = dot(rgb, vec3(Kr, Kg, Kb));
    float Db =  1.505 * (rgb.b - Y);
    float Dr = -1.902 * (rgb.r - Y);

    return vec3(Y, Db, Dr);
}

vec3 YDbDr_to_RGB(vec3 ydd)
{
    float Y  = ydd.x;
    float Db = ydd.y;
    float Dr = ydd.z;

    float R = Y + Dr / -1.902;
    float B = Y + Db /  1.505;
    float G = (Y - Kr * R - Kb * B) / Kg;

    return vec3(R, G, B);
}

vec3 RGB_to_YCgCo(vec3 rgb)
{
    float Y  = 0.5 * rgb.g + 0.25 * (rgb.r + rgb.b);
    float Cg = 0.5 * rgb.g - 0.25 * (rgb.r + rgb.b);
    float Co = 0.5 * (rgb.r - rgb.b);

    return vec3(Y, Cg, Co);
}

vec3 YCgCo_to_RGB(vec3 ycc)
{
    float Y  = ycc.x;
    float Cg = ycc.y;
    float Co = ycc.z;

    float R = Y - Cg + Co;
    float G = Y + Cg;
    float B = Y - Cg - Co;

    return vec3(R, G, B);
}
