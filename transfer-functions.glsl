/*
    -- References --
    https://cdn.standards.iteh.ai/samples/35876/24e0310d04e54233abf5d067e49a8eb7/IEC-61966-2-2-2003.pdf
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.1886-0-201103-I!!PDF-E.pdf
    https://pub.smpte.org/doc/st2084/20140816-pub/
    https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2100-3-202502-I!!PDF-E.pdf
    https://pub.smpte.org/doc/st240/19991111-pub/
*/

/*
    -- Transfer Functions --
    EOTF: Maps nonlinear to display-linear
    OETF: Maps scene-linear to nonlinear
    OOTF: Maps scene-linear to display-linear
*/

vec3 sRGB_EOTF(vec3 RGB)
{
    return mix(
        pow((RGB + 0.055) / 1.055, vec3(2.4)),
        RGB / 12.92,
        lessThanEqual(RGB, vec3(0.04045))
    );
}

vec3 sRGB_inverse_EOTF(vec3 RGB)
{
    return mix(
        1.055 * pow(RGB, vec3(1.0 / 2.4)) - 0.055,
        12.92 * RGB,
        lessThanEqual(RGB, vec3(0.0031308))
    );
}

vec3 BT709_OETF(vec3 RGB)
{
    return mix(
        1.099 * pow(RGB, vec3(0.45)) - 0.099,
        4.5 * RGB,
        lessThan(RGB, vec3(0.018))
    );
}

vec3 BT709_inverse_OETF(vec3 RGB)
{
    return mix(
        pow((RGB + 0.099) / 1.099, vec3(1.0 / 0.45)),
        RGB / 4.5,
        lessThan(RGB, vec3(0.081))
    );
}

vec3 BT1886_EOTF(vec3 RGB)
{
    return pow(RGB, vec3(2.4));
}

vec3 BT1886_inverse_EOTF(vec3 RGB)
{
    return pow(RGB, vec3(1.0 / 2.4));
}

#define CRT_GAMMA1 2.6
#define CRT_GAMMA2 3.0
#define CRT_BREAKPOINT 0.35

vec3 CRT_EOTF(vec3 RGB)
{
    return mix(
        pow(RGB, vec3(CRT_GAMMA1)),
        pow(CRT_BREAKPOINT, CRT_GAMMA1 - CRT_GAMMA2) * pow(RGB, vec3(CRT_GAMMA2)),
        lessThan(RGB, vec3(CRT_BREAKPOINT))
    );
}

vec3 CRT_inverse_EOTF(vec3 RGB)
{
    return mix(
        pow(RGB, vec3(1.0 / CRT_GAMMA1)),
        pow(RGB / pow(CRT_BREAKPOINT, CRT_GAMMA1 - CRT_GAMMA2), vec3(1.0 / CRT_GAMMA2)),
        lessThan(RGB, vec3(pow(CRT_BREAKPOINT, CRT_GAMMA1)))
    );
}

#define PQ_M1 (2610.0 / 4096.0 * 0.25)
#define PQ_M2 (2523.0 / 4096.0 * 128.0)
#define PQ_C1 (PQ_C3 - PQ_C2 + 1.0)
#define PQ_C2 (2413.0 / 4096.0 * 32.0)
#define PQ_C3 (2392.0 / 4096.0 * 32.0)

vec3 PQ_EOTF(vec3 RGB)
{
    const vec3 N = pow(RGB, vec3(1.0 / PQ_M2));

    return pow(max(N - PQ_C1, vec3(0.0)) / (PQ_C2 - PQ_C3 * N), vec3(1.0 / PQ_M1));
}

vec3 PQ_inverse_EOTF(vec3 RGB)
{
    const vec3 L = pow(RGB, vec3(PQ_M1));

    return pow((PQ_C1 + PQ_C2 * L) / (1.0 + PQ_C3 * L), vec3(PQ_M2));
}

vec3 PQ_OOTF(vec3 RGB)
{
    const vec3 E = max(RGB, vec3(0.0));

    const vec3 E709 = mix(
        1.099 * pow(59.5208 * E, vec3(0.45)) - 0.099,
        267.84 * E,
        lessThanEqual(E, vec3(0.0003024))
    );

    return 100.0 * pow(E709, vec3(2.4));
}

vec3 PQ_inverse_OOTF(vec3 RGB)
{
    const vec3 E709 = pow(max(RGB, vec3(0.0)) / 100.0, vec3(1.0 / 2.4));

    return mix(
        pow((E709 + 0.099) / 1.099, vec3(1.0 / 0.45)) / 59.5208,
        E709 / 267.84,
        lessThanEqual(E709, vec3(267.84 * 0.0003024))
    );
}

vec3 PQ_OETF(vec3 RGB)
{
    return PQ_inverse_EOTF(PQ_OOTF(RGB) / 10000.0);
}

vec3 PQ_inverse_OETF(vec3 RGB)
{
    return PQ_inverse_OOTF(PQ_EOTF(RGB) * 10000.0);
}

#define HLG_A 0.17883277
#define HLG_B (1.0 - 4.0 * HLG_A)
#define HLG_C (0.5 - HLG_A * log(4.0 * HLG_A))

vec3 HLG_OETF(vec3 RGB)
{
    return mix(
        HLG_A * log(max(12.0 * RGB - HLG_B, vec3(4.0 * HLG_A))) + HLG_C,
        sqrt(3.0 * RGB),
        lessThanEqual(RGB, vec3(1.0 / 12.0))
    );
}

vec3 HLG_inverse_OETF(vec3 RGB)
{
    return mix(
        (exp((RGB - HLG_C) / HLG_A) + HLG_B) / 12.0,
        RGB * RGB / 3.0,
        lessThanEqual(RGB, vec3(0.5))
    );
}

#define HLG_ALPHA 1000.0
#define HLG_GAMMA 1.2

vec3 HLG_OOTF(vec3 RGB)
{
    const float Y = dot(RGB, vec3(0.2627, 0.6780, 0.0593));

    return HLG_ALPHA * pow(Y, HLG_GAMMA - 1.0) * RGB;
}

vec3 HLG_inverse_OOTF(vec3 RGB)
{
    const float Y = dot(RGB, vec3(0.2627, 0.6780, 0.0593));

    if (Y <= 0.0) return vec3(0.0);

    return pow(Y / HLG_ALPHA, (1.0 - HLG_GAMMA) / HLG_GAMMA) * RGB / HLG_ALPHA;
}

vec3 HLG_EOTF(vec3 RGB)
{
    return HLG_OOTF(HLG_inverse_OETF(RGB));
}

vec3 HLG_inverse_EOTF(vec3 RGB)
{
    return HLG_OETF(HLG_inverse_OOTF(RGB));
}

vec3 ST240_EOTF(vec3 RGB)
{
    return mix(
        pow((RGB + 0.1115) / 1.1115, vec3(1.0 / 0.45)),
        RGB / 4.0,
        lessThan(RGB, vec3(0.0913))
    );
}

vec3 ST240_OETF(vec3 RGB)
{
    return mix(
        1.1115 * pow(RGB, vec3(0.45)) - 0.1115,
        4.0 * RGB,
        lessThan(RGB, vec3(0.0228))
    );
}
