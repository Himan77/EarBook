class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  
  #default_scope order: 'microposts.created_at DESC'

  # scope :order_by_created, order("created_at DESC")
  scope :recent, -> { order(created_at: :desc) }
  scope :order_by_views, -> { order(views: :desc) }
  

  

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

  def self.dedupe
    # find all models and group them on keys which should be common
    grouped = all.group_by{|micropost| [micropost.video_id,micropost.user_id] }
    
    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      puts duplicates
      duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
    
  end

  
end

#Micropost.dedupe