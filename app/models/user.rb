class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :points
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def self.save(users)
    
    name =  users['datafile'].original_filename
    directory = "public/data/"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(users['datafile'].read) }
  end

  def populate(user)
    
    File.open("public/data/out.txt", "r") do |f|
      
      f.each_line do |line|

        line.delete!("\n")

        
        post = Micropost.new do |p|
          p.content,p.artist,p.views,p.video_id = line.split(",")
          p.user_id = user.id
        end
        post.save!
      end
    end
    
  end

  def popular
    allusers = User.all 
    array = []
    allusers.each do |u|
      cnt = u.points
      temp1 = [cnt, u.id]
      array.push temp1
    end
    array = array.sort_by{|x,y|x}.reverse
    ids = []
    (0..4).each {|i|  ids << array[i][1] }
    puts ids
    
    
    

    users_sorted = []
    ids.each do |uid|
      users_sorted << User.find(uid)

    end
    puts users_sorted
    
    return users_sorted

  end

  def generate_recommendation(user)
   
    arr = []
    #f = File.open("public/data/top5.txt", "w")
    #total = user.microposts.count
    allusers = (user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", user.id]))

    allusers.each do |other_user|
      count = 0
      if user.following?(other_user)
        next
      end
      user.microposts.each do |current_user_song|
        other_user.microposts.each do |other_user_song|
          if current_user_song.video_id ==  other_user_song.video_id 
            count = count + 1
            break
          end
        end
      end
    
      temp = [count, other_user.id]
      arr.push temp
      #f.puts(score.to_s+","+other_user.id)
    end
    

    arr = arr.sort_by{|x,y|x}.reverse 
    users_array = []
    (0..4).each {|i|  users_array << arr[i][1] }
    puts users_array
    
    
    

    users = []
    users_array.each do |uid|
      users << User.find(uid)

    end
    return users
  end

   
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
