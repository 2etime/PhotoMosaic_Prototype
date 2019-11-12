#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float3 position [[ attribute(0) ]];
    float2 textureCoordinate [[ attribute(1) ]];
};

struct SceneConstants {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct ModelConstants {
    float4x4 modelMatrix;
    float4 averageColor;
    int slice;
};

struct RasterizerData {
    float4 position [[ position ]];
    float2 textureCoordinate;
    float3 worldPosition;
    float4 averageColor;
    int slice;
};

vertex RasterizerData vertex_shader(Vertex vIn [[ stage_in ]],
                                    constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                    constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1.0);
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.averageColor = modelConstants.averageColor;
    
    return rd;
}

vertex RasterizerData instanced_vertex_shader(Vertex vIn [[ stage_in ]],
                                              constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                              constant ModelConstants *modelConstants [[ buffer(2) ]],
                                              uint instanceId [[ instance_id ]]) {
    RasterizerData rd;
    ModelConstants modelConstant = modelConstants[instanceId];
    
    float4 worldPosition = modelConstant.modelMatrix * float4(vIn.position, 1.0);
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.slice = modelConstant.slice;
    rd.averageColor = modelConstant.averageColor;
    
    return rd;
}

fragment half4 fragment_shader(RasterizerData rd [[ stage_in ]],
                                      sampler sampler2d [[ sampler(0) ]],
                                      texture2d<float> texture [[ texture(0) ]]) {
    float4 color = texture.sample(sampler2d, rd.textureCoordinate);

    return half4(color);
}

fragment half4 mosaic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                      sampler sampler2d [[ sampler(0) ]],
                                      constant bool &useAverage [[ buffer(1) ]],
                                      texture2d_array<float> texture [[ texture(0) ]]) {
    if(rd.slice == -1) {
        return half4(0.03);
    }
    
    float4 color = texture.sample(sampler2d, rd.textureCoordinate, rd.slice);
    
    float4 averageColor = rd.averageColor;
//    averageColor = pow(averageColor, 2.2);
    
    if(useAverage) {
        color *= averageColor;        
    }
//
//    float lineWidth = 0.01;
//    float2 texCoord = rd.textureCoordinate;
//    
//    float x = fract(texCoord.x);
//    float y = fract(texCoord.y);
//    if (x < lineWidth ||
//        y < lineWidth ||
//        x > 1 - lineWidth ||
//        y > 1 - lineWidth){
//        color = float4(0,0,0,1);
//    }
    
    return half4(color);
}
