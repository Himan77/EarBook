class AddViewsVideoIdToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :views, :integer
    add_column :microposts, :video_id, :string
  end
end
