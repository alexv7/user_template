class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email   # before_save { self.email = email.downcase }  # we created a method for this now
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}
  # validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # In case you’re worried that Listing 9.10 might allow new users to sign up
  # with empty passwords, recall from Section 6.3.3 that has_secure_password
  # includes a separate presence validation that specifically catches nil
  # passwords. (Because nil passwords now bypass the main presence validation but
  # are still caught by has_secure_password , this also fixes the duplicate error
  # message mentioned in Section 7.3.3.).
  # Basically what this is doing is that when updating/editing the user attributes, if
  # the user does not update the password and confirmation fields (leaves it nil)
  # then it will keep its password as the original password that they
  # used when they signed up.


  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # $ rails console
  #   >> a = [1, 2, 3]
  #   >> a.length
  #   => 3
  #   >> a.send(:length)
  #   => 3
  #   >> a.send('length')
  #   => 3

    # >> user = User.first
    # >> user.activation_digest
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> user.send(:activation_digest)
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> user.send('activation_digest')
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> attribute = :activation
    # >> user.send("#{attribute}_digest")
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"

  # Returns true if the given token matches the digest.
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired. “Password reset sent earlier than thirty minutes ago.”
  def password_reset_expired?
    reset_sent_at < 30.minutes.ago
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end





=begin



Expression	Meaning

/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i	full regex

/	start of regex

\A	match start of a string

[\w+\-.]+	at least one word character, plus, hyphen, or dot

@	literal “at sign”

[a-z\d\-.]+	at least one letter, digit, hyphen, or dot

\.	literal dot

[a-z]+	at least one letter

\z	match end of a string

/	end of regex

i	case-insensitive

Table 6.1: Breaking down the valid email regex.



=end
