#define TILE_WIDTH 16
#define TILE_HEIGHT 16
#define SH_MAX_COEFFS 48

#ifdef DEBUG
#extension GL_EXT_debug_printf : enable
#define assert( condition, message, value ) if( ! bool(condition) ){ \
       debugPrintfEXT( message, value ); \
     }
#else
#define assert( condition, message, value )
#endif

#define MAGIC 0x4d415449u

const float lowest_alpha_coeff = 5.54126354515842f;
const float SH_C0 = 0.28209479177387814f;
const float SH_C1 = 0.4886025119029199f;
const float SH_C2[] = {
1.0925484305920792f,
-1.0925484305920792f,
0.31539156525252005f,
-1.0925484305920792f,
0.5462742152960396f
};
const float SH_C3[] = {
-0.5900435899266435f,
2.890611442640554f,
-0.4570457994644658f,
0.3731763325901154f,
-0.4570457994644658f,
1.445305721320277f,
-0.5900435899266435f
};

const float inv_exp_lut_step = -31.0f/5.6f;

const float lut[] = {
1.0,
0.8347315012000831,
0.6967766790957444,
0.5816214433427993,
0.48549774053169403,
0.40526025778326935,
0.33828350335616114,
0.2823758965877118,
0.23570805606138007,
0.19675293948106914,
0.16423587653856195,
0.13709285977394534,
0.1144357286429179,
0.0955231075610282,
0.07973614697371409,
0.06655827366327882,
0.05555828769223469,
0.04637625288944516,
0.03871171919444125,
0.032313891477212024,
0.026973423142389763,
0.02251556599215207,
0.018794452200998634,
0.015688321299972805,
0.01309553599003554,
0.010931256415982082,
0.009124664078115763,
0.007616644543872045,
0.006357853134213734,
0.005307100291131884,
0.004430003793035916,
0.003697863716482932
};

struct Vertex {
    vec4 position;
    vec4 scale_opacity;
    vec4 rotation;
    float sh[48];
};

struct VertexAttribute {
    vec4 conic_opacity;
    vec4 color_radii;
    uvec4 aabb;
    vec2 uv;
    float depth;
    uint magic;
};

mat3 rotationFromQuaternion(vec4 q) {
    float qx = q.y;
    float qy = q.z;
    float qz = q.w;
    float qw = q.x;

    float qx2 = qx * qx;
    float qy2 = qy * qy;
    float qz2 = qz * qz;

    mat3 rotationMatrix;
    rotationMatrix[0][0] = 1 - 2 * qy2 - 2 * qz2;
    rotationMatrix[0][1] = 2 * qx * qy - 2 * qz * qw;
    rotationMatrix[0][2] = 2 * qx * qz + 2 * qy * qw;

    rotationMatrix[1][0] = 2 * qx * qy + 2 * qz * qw;
    rotationMatrix[1][1] = 1 - 2 * qx2 - 2 * qz2;
    rotationMatrix[1][2] = 2 * qy * qz - 2 * qx * qw;

    rotationMatrix[2][0] = 2 * qx * qz - 2 * qy * qw;
    rotationMatrix[2][1] = 2 * qy * qz + 2 * qx * qw;
    rotationMatrix[2][2] = 1 - 2 * qx2 - 2 * qy2;

    return rotationMatrix;
}