require "bcrypt"

class User < Sequel::Model
  one_to_many :ads
  one_to_many :comments
  one_to_many :discussions
  one_to_many :payments

  def password
    BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end

  def admin?() permission == "admin" end
  
  def my_campaigns
    user_ads = Payment.select(:ad_id).where(:email => self.email).distinct
    ad = Ad.where(:id => user_ads)
    return ad
  end
  
   def other_campaigns
    user_ads = Payment.select(:ad_id).where(:email => self.email).distinct
    ad = Ad.exclude(:id => user_ads)
    return ad
  end
  
end
