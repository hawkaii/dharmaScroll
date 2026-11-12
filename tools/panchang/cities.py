"""Bundled cities: name, country, latitude, longitude (deg), IANA time zone.

Coordinates are city-centre values rounded to 0.01 deg; that is far inside the
accuracy that matters (1 deg of longitude moves sunrise by 4 minutes).
"""

IST = "Asia/Kolkata"

# (name, state/country, lat, lon, tz)
_INDIA = """
New Delhi|IN|28.61|77.21
Mumbai|IN|19.08|72.88
Kolkata|IN|22.57|88.36
Chennai|IN|13.08|80.27
Bengaluru|IN|12.97|77.59
Hyderabad|IN|17.38|78.49
Ahmedabad|IN|23.02|72.57
Pune|IN|18.52|73.86
Surat|IN|21.17|72.83
Jaipur|IN|26.91|75.79
Lucknow|IN|26.85|80.95
Kanpur|IN|26.45|80.33
Nagpur|IN|21.15|79.09
Indore|IN|22.72|75.86
Bhopal|IN|23.26|77.41
Visakhapatnam|IN|17.69|83.22
Patna|IN|25.59|85.14
Vadodara|IN|22.31|73.18
Ghaziabad|IN|28.67|77.45
Ludhiana|IN|30.90|75.86
Agra|IN|27.18|78.02
Nashik|IN|20.00|73.79
Faridabad|IN|28.41|77.31
Meerut|IN|28.98|77.71
Rajkot|IN|22.30|70.80
Varanasi|IN|25.32|82.97
Srinagar|IN|34.08|74.80
Aurangabad|IN|19.88|75.34
Dhanbad|IN|23.80|86.43
Amritsar|IN|31.63|74.87
Prayagraj|IN|25.44|81.85
Ranchi|IN|23.34|85.31
Howrah|IN|22.59|88.31
Coimbatore|IN|11.02|76.96
Jabalpur|IN|23.18|79.99
Gwalior|IN|26.22|78.18
Vijayawada|IN|16.51|80.65
Jodhpur|IN|26.24|73.02
Madurai|IN|9.93|78.12
Raipur|IN|21.25|81.63
Kota|IN|25.18|75.84
Chandigarh|IN|30.73|76.78
Guwahati|IN|26.14|91.74
Solapur|IN|17.66|75.91
Hubballi|IN|15.36|75.12
Mysuru|IN|12.30|76.64
Tiruchirappalli|IN|10.79|78.70
Bareilly|IN|28.37|79.43
Aligarh|IN|27.88|78.08
Tiruppur|IN|11.11|77.34
Moradabad|IN|28.84|78.78
Jalandhar|IN|31.33|75.58
Bhubaneswar|IN|20.30|85.82
Salem|IN|11.66|78.15
Warangal|IN|17.97|79.59
Thiruvananthapuram|IN|8.52|76.94
Guntur|IN|16.31|80.44
Bhiwandi|IN|19.30|73.06
Gorakhpur|IN|26.76|83.37
Bikaner|IN|28.02|73.31
Amravati|IN|20.93|77.75
Noida|IN|28.54|77.39
Jamshedpur|IN|22.80|86.20
Bhilai|IN|21.21|81.38
Cuttack|IN|20.46|85.88
Kochi|IN|9.93|76.27
Dehradun|IN|30.32|78.03
Udaipur|IN|24.59|73.71
Ajmer|IN|26.45|74.64
Kolhapur|IN|16.70|74.24
Ujjain|IN|23.18|75.78
Mangaluru|IN|12.91|74.86
Belagavi|IN|15.85|74.50
Jamnagar|IN|22.47|70.06
Gulbarga|IN|17.33|76.83
Jammu|IN|32.73|74.87
Tirunelveli|IN|8.71|77.76
Gaya|IN|24.80|85.00
Jalgaon|IN|21.00|75.57
Kozhikode|IN|11.26|75.78
Thrissur|IN|10.53|76.21
Haridwar|IN|29.95|78.16
Rishikesh|IN|30.09|78.27
Mathura|IN|27.49|77.67
Vrindavan|IN|27.58|77.70
Ayodhya|IN|26.80|82.20
Nathdwara|IN|24.93|73.82
Dwarka|IN|22.24|68.97
Somnath|IN|20.89|70.40
Puri|IN|19.81|85.83
Tirupati|IN|13.63|79.42
Rameswaram|IN|9.29|79.31
Shirdi|IN|19.77|74.48
Pandharpur|IN|17.68|75.33
Kurukshetra|IN|29.97|76.88
Nanded|IN|19.15|77.32
Sangli|IN|16.85|74.57
Latur|IN|18.40|76.56
Akola|IN|20.71|77.00
Davangere|IN|14.47|75.92
Shivamogga|IN|13.93|75.57
Vellore|IN|12.92|79.13
Erode|IN|11.34|77.72
Thanjavur|IN|10.79|79.14
Kanchipuram|IN|12.83|79.70
Pondicherry|IN|11.93|79.83
Nellore|IN|14.44|79.99
Kurnool|IN|15.83|78.04
Rajahmundry|IN|17.00|81.80
Kakinada|IN|16.99|82.25
Karimnagar|IN|18.44|79.13
Nizamabad|IN|18.67|78.09
Khammam|IN|17.25|80.15
Alappuzha|IN|9.49|76.34
Kollam|IN|8.89|76.61
Kannur|IN|11.87|75.37
Panaji|IN|15.50|73.83
Margao|IN|15.27|73.96
Shimla|IN|31.10|77.17
Manali|IN|32.24|77.19
Srinagar Garhwal|IN|30.22|78.78
Nainital|IN|29.38|79.46
Haldwani|IN|29.22|79.51
Roorkee|IN|29.85|77.89
Saharanpur|IN|29.96|77.55
Muzaffarpur|IN|26.12|85.39
Darbhanga|IN|26.15|85.90
Bhagalpur|IN|25.24|86.97
Purnia|IN|25.78|87.47
Siliguri|IN|26.73|88.43
Durgapur|IN|23.52|87.31
Asansol|IN|23.68|86.97
Kharagpur|IN|22.35|87.23
Gangtok|IN|27.33|88.61
Shillong|IN|25.58|91.89
Imphal|IN|24.82|93.94
Agartala|IN|23.83|91.28
Aizawl|IN|23.73|92.72
Kohima|IN|25.67|94.11
Itanagar|IN|27.08|93.62
Dibrugarh|IN|27.48|94.91
Jorhat|IN|26.76|94.20
Silchar|IN|24.83|92.78
Sambalpur|IN|21.47|83.97
Rourkela|IN|22.26|84.85
Bilaspur|IN|22.08|82.15
Korba|IN|22.35|82.68
Rewa|IN|24.53|81.30
Sagar|IN|23.84|78.74
Satna|IN|24.60|80.83
Chitrakoot|IN|25.20|80.85
Jhansi|IN|25.45|78.57
Firozabad|IN|27.15|78.40
Mirzapur|IN|25.15|82.57
Sonipat|IN|28.99|77.02
Panipat|IN|29.39|76.97
Ambala|IN|30.38|76.78
Hisar|IN|29.15|75.72
Rohtak|IN|28.89|76.61
Gurugram|IN|28.46|77.03
Patiala|IN|30.34|76.39
Bathinda|IN|30.21|74.95
Sri Ganganagar|IN|29.92|73.88
Alwar|IN|27.57|76.61
Bhilwara|IN|25.35|74.64
Pushkar|IN|26.49|74.55
Jaisalmer|IN|26.92|70.91
Navi Mumbai|IN|19.03|73.03
Thane|IN|19.22|72.98
Vasai|IN|19.39|72.84
Port Blair|IN|11.62|92.73
"""

# (name, country, lat, lon, tz)
_WORLD = [
    ("New York", "US", 40.71, -74.01, "America/New_York"),
    ("Edison", "US", 40.52, -74.41, "America/New_York"),
    ("Fairfield", "US", 41.14, -73.26, "America/New_York"),
    ("Boston", "US", 42.36, -71.06, "America/New_York"),
    ("Philadelphia", "US", 39.95, -75.17, "America/New_York"),
    ("Washington DC", "US", 38.91, -77.04, "America/New_York"),
    ("Atlanta", "US", 33.75, -84.39, "America/New_York"),
    ("Miami", "US", 25.76, -80.19, "America/New_York"),
    ("Chicago", "US", 41.88, -87.63, "America/Chicago"),
    ("Dallas", "US", 32.78, -96.80, "America/Chicago"),
    ("Houston", "US", 29.76, -95.37, "America/Chicago"),
    ("Austin", "US", 30.27, -97.74, "America/Chicago"),
    ("Denver", "US", 39.74, -104.99, "America/Denver"),
    ("Phoenix", "US", 33.45, -112.07, "America/Phoenix"),
    ("San Francisco", "US", 37.77, -122.42, "America/Los_Angeles"),
    ("San Jose", "US", 37.34, -121.89, "America/Los_Angeles"),
    ("Los Angeles", "US", 34.05, -118.24, "America/Los_Angeles"),
    ("Seattle", "US", 47.61, -122.33, "America/Los_Angeles"),
    ("Toronto", "CA", 43.65, -79.38, "America/Toronto"),
    ("Brampton", "CA", 43.73, -79.76, "America/Toronto"),
    ("Montreal", "CA", 45.50, -73.57, "America/Toronto"),
    ("Calgary", "CA", 51.05, -114.07, "America/Edmonton"),
    ("Edmonton", "CA", 53.55, -113.49, "America/Edmonton"),
    ("Vancouver", "CA", 49.28, -123.12, "America/Vancouver"),
    ("London", "GB", 51.51, -0.13, "Europe/London"),
    ("Leicester", "GB", 52.64, -1.13, "Europe/London"),
    ("Birmingham", "GB", 52.49, -1.89, "Europe/London"),
    ("Manchester", "GB", 53.48, -2.24, "Europe/London"),
    ("Dublin", "IE", 53.35, -6.26, "Europe/Dublin"),
    ("Amsterdam", "NL", 52.37, 4.90, "Europe/Amsterdam"),
    ("Paris", "FR", 48.86, 2.35, "Europe/Paris"),
    ("Berlin", "DE", 52.52, 13.41, "Europe/Berlin"),
    ("Frankfurt", "DE", 50.11, 8.68, "Europe/Berlin"),
    ("Zurich", "CH", 47.38, 8.54, "Europe/Zurich"),
    ("Stockholm", "SE", 59.33, 18.07, "Europe/Stockholm"),
    ("Dubai", "AE", 25.20, 55.27, "Asia/Dubai"),
    ("Abu Dhabi", "AE", 24.45, 54.38, "Asia/Dubai"),
    ("Doha", "QA", 25.29, 51.53, "Asia/Qatar"),
    ("Muscat", "OM", 23.59, 58.41, "Asia/Muscat"),
    ("Kuwait City", "KW", 29.38, 47.99, "Asia/Kuwait"),
    ("Riyadh", "SA", 24.71, 46.68, "Asia/Riyadh"),
    ("Singapore", "SG", 1.35, 103.82, "Asia/Singapore"),
    ("Kuala Lumpur", "MY", 3.14, 101.69, "Asia/Kuala_Lumpur"),
    ("Hong Kong", "HK", 22.32, 114.17, "Asia/Hong_Kong"),
    ("Tokyo", "JP", 35.68, 139.69, "Asia/Tokyo"),
    ("Sydney", "AU", -33.87, 151.21, "Australia/Sydney"),
    ("Melbourne", "AU", -37.81, 144.96, "Australia/Melbourne"),
    ("Perth", "AU", -31.95, 115.86, "Australia/Perth"),
    ("Brisbane", "AU", -27.47, 153.03, "Australia/Brisbane"),
    ("Auckland", "NZ", -36.85, 174.76, "Pacific/Auckland"),
    ("Johannesburg", "ZA", -26.20, 28.05, "Africa/Johannesburg"),
    ("Durban", "ZA", -29.86, 31.02, "Africa/Johannesburg"),
    ("Nairobi", "KE", -1.29, 36.82, "Africa/Nairobi"),
    ("Port Louis", "MU", -20.16, 57.50, "Indian/Mauritius"),
    ("Kathmandu", "NP", 27.72, 85.32, "Asia/Kathmandu"),
    ("Colombo", "LK", 6.93, 79.86, "Asia/Colombo"),
    ("Dhaka", "BD", 23.81, 90.41, "Asia/Dhaka"),
    ("Port of Spain", "TT", 10.66, -61.51, "America/Port_of_Spain"),
    ("Georgetown", "GY", 6.80, -58.16, "America/Guyana"),
    ("Paramaribo", "SR", 5.85, -55.20, "America/Paramaribo"),
]


def _slug(name: str, country: str) -> str:
    return (name.lower().replace(" ", "-") + "-" + country.lower())


def all_cities() -> list[dict]:
    out = []
    for line in _INDIA.strip().splitlines():
        name, c, lat, lon = line.split("|")
        out.append((name, c, float(lat), float(lon), IST))
    out.extend(_WORLD)
    cities = []
    for name, c, lat, lon, tz in out:
        cities.append(
            {"id": _slug(name, c), "name": name, "country": c,
             "lat": lat, "lon": lon, "tz": tz}
        )
    assert len({c["id"] for c in cities}) == len(cities), "duplicate city id"
    return cities


if __name__ == "__main__":
    print(len(all_cities()))
