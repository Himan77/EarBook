class StaticPagesController < ApplicationController

  def home
    
    if signed_in?
      #@users = current_user.generate_recommendation(current_user)
      
      @users = current_user.generate_recommendation(current_user)
      @allusers = current_user.popular
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end

  end

  def help
  end

  def about
  end

  def contact
  end

end
