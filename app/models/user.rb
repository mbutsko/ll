class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weight_entries
  has_many :hrv_entries
  has_many :rhr_entries
  has_many :step_entries

  before_create :set_api_token

  def generate_api_token!
    update!(api_token: SecureRandom.hex(32))
  end

  private

  def set_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
