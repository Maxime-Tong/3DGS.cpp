#ifndef GSSCENE_H
#define GSSCENE_H

#include <filesystem>
#include <iostream>
#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>
#include "vulkan/VulkanContext.h"
#include "vulkan/Buffer.h"

struct PlyProperty {
    std::string type;
    std::string name;
};

struct PlyHeader {
    std::string format;
    int numVertices;
    int numFaces;
    std::vector<PlyProperty> vertexProperties;
    std::vector<PlyProperty> faceProperties;
};

class GSScene {
public:
    explicit GSScene(const std::string& filename, const std::string& _clusterPath)
        : filename(filename), clusterPath(_clusterPath), use_cluster(true) {
        // check if file exists
        if (!std::filesystem::exists(filename)) {
            throw std::runtime_error("File does not exist: " + filename);
        }
        // check if cluster folder exists
        if (!std::filesystem::exists(clusterPath)) {
            throw std::runtime_error("Cluster folder does not exist: " + clusterPath);
        }
    }

    explicit GSScene(const std::string& filename)
        : filename(filename), use_cluster(false) {
        // check if file exists
        if (!std::filesystem::exists(filename)) {
            throw std::runtime_error("File does not exist: " + filename);
        }
    }

    void load(const std::shared_ptr<VulkanContext>& context);

    void loadTestScene(const std::shared_ptr<VulkanContext>& context);

    uint64_t getNumVertices() const {
        return header.numVertices;
    }

    struct Vertex {
        glm::vec4 position;
        glm::vec4 scale_opacity;
        glm::vec4 rotation;
        float shs[48];
    };

    // struct Scaler {
    //     glm::vec3 position_mean;
    //     glm::vec4 rotation_mean;
    //     glm::vec3 position_scale;
    //     glm::vec4 rotation_scale;
    // };

    struct clusterFeature {
        glm::vec3 position; // x, y, z
        glm::quat rotation; // w, a, b, c
        int numGaussians;

        float distance(const clusterFeature& other) const {
            glm::vec3 dp = (position - other.position);

            glm::vec4 q1(rotation.w, rotation.x, rotation.y, rotation.z);
            glm::vec4 q2(other.rotation.w, other.rotation.x, other.rotation.y, other.rotation.z);
            glm::vec4 dr = (q1 - q2);

            return glm::dot(dp, dp) + glm::dot(dr, dr);
        }
    };

    struct Cov3DUpperRight {
        float mat[6];
    };

    std::shared_ptr<Buffer> vertexBuffer;
    std::shared_ptr<Buffer> cov3DBuffer;
    std::shared_ptr<Buffer> clusterMaskBuffer;
    
    bool use_cluster;
    std::vector<clusterFeature> clusters;
    // Scaler scaler;
    
private:
    std::string filename;
    std::string clusterPath;

    PlyHeader header;

    std::shared_ptr<Buffer> createStagingBuffer(const std::shared_ptr<VulkanContext>& sharedPtr, unsigned long i);

    void loadPlyHeader(std::ifstream& ifstream);

    static std::shared_ptr<Buffer> createBuffer(const std::shared_ptr<VulkanContext>& sharedPtr, size_t i);

    void precomputeCov3D(const std::shared_ptr<VulkanContext>& context);
};



#endif //GSSCENE_H
