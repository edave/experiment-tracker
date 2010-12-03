class User < ObfuscatedRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable

  # Add ACL9's support for roles/authorization
  acts_as_authorization_subject  :association_name => :roles

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_name, :name, :phone
  attr_readonly :user_name
 
  before_save :clean_phone
  
  # Custom habtms
  has_many :experiments
  belongs_to :group

  validates_presence_of     :user_name
  validates_presence_of     :name
  #validates_length_of        :user_name,    :within => @@login_length..40
  validates_uniqueness_of    :user_name, :case_sensitive => false
  #validates_length_of :phone, :minimum => 10, :allow_blank => true, :allow_nil => true
  
  def clean_phone
    unless self.phone.nil?
     self.phone = self.phone.gsub(/[^\d]/,'')
    end
  end
  
end
