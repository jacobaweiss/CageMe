require 'sinatra/base'
require 'rmagick'

class Cageme << Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'
  Pic = Struct.new(:image, :width, :height)

  def self.preload_images
    images = []
    Dir.entries('./public/images').collect{ |f| f if f =~ /\.jpg/ }.compact.each do |img|
      pic = Magick::Image.read("./public/images/#{img}").first
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
    content_type 'image/jpg'
    random_cage.to_blob
  end
end