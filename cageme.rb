require 'sinatra/base'
require 'RMagick'

class Cageme < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'
  Pic = Struct.new(:image, :width, :height)

  def self.preload_images
    images = []
    Dir.glob('./public/images/*.jpg').each do |img|
      pic = Magick::Image.read("#{img}").first
      p = Pic.new(pic, pic.columns, pic.rows)
      images.push p
    end
    return images
  end

  def random_cage
    PICS[rand(PICS.count)].image
  end

  PICS = preload_images

  get "/" do
    erb :index
  end

  get "/random" do
    content_type 'image/jpeg'
    random_cage.to_blob
  end
end