class User < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :bio, length: { maximum: 500 }
  
  scope :search, ->(query) { where("name ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%") }
  
  def display_name
    name.presence || email.split('@').first
  end
  
  def avatar_url
    "https://ui-avatars.com/api/?name=#{CGI.escape(name)}&size=100&background=random"
  end
end 