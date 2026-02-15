[
  { slug: "weight", name: "Weight", units: "lbs", reference_min: 155, reference_max: 175, delta_down_is_good: true },
  { slug: "hrv", name: "Heart Rate Variability", units: "ms", reference_min: 50, reference_max: nil, delta_down_is_good: false },
  { slug: "rhr", name: "Resting Heart Rate", units: "bpm", reference_min: nil, reference_max: nil, delta_down_is_good: true },
  { slug: "steps", name: "Steps", units: nil, reference_min: nil, reference_max: nil, delta_down_is_good: false },
  { slug: "hba1c", name: "HbA1c", units: "%", reference_min: nil, reference_max: 5.5, delta_down_is_good: true },
].each do |attrs|
  Metric.find_or_create_by!(slug: attrs[:slug]) do |m|
    m.name = attrs[:name]
    m.units = attrs[:units]
    m.reference_min = attrs[:reference_min]
    m.reference_max = attrs[:reference_max]
    m.delta_down_is_good = attrs[:delta_down_is_good]
  end
end
