import joblib
import json
import os

path = r"scenes\mini_seele_sparse_v2\plant_whitepalm\clusters\clusters.pkl"
save_path = r"scenes\mini_seele_sparse_v2\plant_whitepalm\clusters\clusters.json"
cluster_pkg = joblib.load(path)
print(cluster_pkg.keys())

pkg_transfered = {
    "centers": cluster_pkg["centers"].tolist(), # [camer_center, quaternion], dtype: float32
    "gaussian_idxs": [data[0].tolist() for data in cluster_pkg["cluster_gaussians"]], # [num_clusters, num_gaussians], dtype: int32
}

with open(save_path, "w") as f:
    json.dump(pkg_transfered, f, indent=4)  # indent for readability (optional)

print("Saved JSON for C++ nlohmann/json.hpp")