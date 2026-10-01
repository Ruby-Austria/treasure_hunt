module DistanceCalculator
  # Haversine formula — distance between two GPS points in meters
  def self.haversine(lat1, lon1, lat2, lon2)
    rad = Math::PI / 180
    earth_radius = 6_371_000

    dlat = (lat2 - lat1) * rad
    dlon = (lon2 - lon1) * rad

    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1 * rad) * Math.cos(lat2 * rad) *
        Math.sin(dlon / 2)**2

    earth_radius * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end
end
