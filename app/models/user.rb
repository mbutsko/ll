class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :measurements
  has_many :exercise_logs
  has_many :food_logs

  before_create :set_api_token

  def generate_api_token!
    update!(api_token: SecureRandom.hex(32))
  end

  private

  def set_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
