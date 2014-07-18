class UsersController < ApplicationController
  before_filter :signed_in_user,
                only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy

  def show
    Micropost.dedupe
    @user = User.find(params[:id])
    
    @microposts = @user.microposts.order_by_views.paginate(page: params[:page])
  end



  def following
    @title = "Following"
    @user = User.find(params[:id])

    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def new
  	@user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def Add_to_playlist

    @micropost = Micropost.find_by_id(params[:id])
    post = Micropost.new do |p|
      p.content = @micropost.content
      p.artist = @micropost.artist
      p.views = @micropost.views
      p.video_id = @micropost.video_id
      p.user_id = current_user.id
    end
    post.save!
    temp = @micropost.user_id
    user = User.find(temp)
    puts user
    
    point = user.points + 1
    #puts point
    #debugger
    user.update_attribute(:points,point)
    

    # redirect_to root_url
    redirect_to :back

  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to EarBook!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def uploadfile
    if params[:users] == nil
      redirect_to current_user

    
    else
      #puts datafile
      User.save(params[:users])
      #User.views
      load('youtube.rb')
      
      current_user.populate(current_user)
      redirect_to current_user
    end
    
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in." unless signed_in?
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end  

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
