class Metric < ApplicationRecord
  has_many :measurements, dependent: :destroy

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  def self.find_by_slug!(slug)
    find_by!(slug: slug)
  end

  def name_with_units
    units.present? ? "#{name} (#{units})" : name
  end
end
