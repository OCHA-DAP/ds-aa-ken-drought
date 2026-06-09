arid = [
    "Baringo",
    "Mandera",
    "Isiolo",
    "Wajir",
    "Garissa",
    "Marsabit",
    "Turkana",
    "Tana River",
    "Samburu",
]
cell_size = 56000 # 0.5 degree is roughly 55km

ken_epsg = "EPSG:32736"
ken_geo_epsg = "EPSG:4326"
issue_months = ["July", "August", "September"]

thresholds_RP5 = {"July": 35, "August": 30, "September": 30}
quantile_RP5 = 0.4
thresholds_RP5_new = {"Non-Negative": 40, "Negative": 35}
quantile_RP5_new = 0.5

thresholds_RP3 = {"July": 50, "August": 45, "September": 45}
quantile_RP3 = 0.5
thresholds_RP3_new = {"Non-Negative": 60, "Negative": 50}
quantile_RP3_new = 0.5