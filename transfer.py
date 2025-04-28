import joblib
import json
import os

path = r"D:\workspace\master\3DGS\HUAWEI\3dgs.cpp\3DGS.cpp\scenes\mini_seele_sparse_v2\plant_whitepalm\clusters\clusters.pkl"
save_path = r"D:\workspace\master\3DGS\HUAWEI\3dgs.cpp\3DGS.cpp\scenes\mini_seele_sparse_v2\plant_whitepalm\clusters\clusters.json"
cluster_pkg = joblib.load(path)
print(cluster_pkg.keys())
# print(cluster_pkg["centers"].shape)
# print(cluster_pkg["cluster_gaussians"][0][0]) # [num_clusters, 3]

pkg_transfered = {
    "centers": cluster_pkg["centers"].tolist(), # [camer_center, quaternion], dtype: float32
    "gaussian_idxs": [data[0].tolist() for data in cluster_pkg["cluster_gaussians"]], # [num_clusters, num_gaussians], dtype: int32
}
# print([len(data) for data in pkg_transfered["gaussian_idxs"]]) # [num_gaussians]
# Save to JSON file (compatible with nlohmann/json)
with open(save_path, "w") as f:
    json.dump(pkg_transfered, f, indent=4)  # indent for readability (optional)

print("Saved JSON for C++ nlohmann/json.hpp")