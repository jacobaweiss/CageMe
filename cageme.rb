require 'sinatra/base'
require 'RMagick'

class Cageme < Sinatra::Base
  # huge thanks/credit to https://github.com/JGaudette/PlaceDog
  
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
  
  def image_with_size(width, height)
    if width > 3000 || height > 3000
      imgResize = "The image you requested is too big; let's not spread Mr. Cage too thin."
    else
      img = random_cage
      imgResize = img.resize_to_fill(width, height)
    end
    return imgResize
  end

  PICS = preload_images
  
  #### Error Handling
  not_found do
    erb :page_not_found
  end
  
  #### Routes

  get "/" do
    erb :index
  end

  get "/random" do
    # content_type 'image/jpeg'
    # random_cage.to_blob
    
    #new code to render a static, savable, linkable image
    img = random_cage.filename[8..-1]
    redirect "#{img}"
  end
  
  get "/g/random" do
    content_type 'image/jpeg'
    image = random_cage.quantize(256, Magick::GRAYColorspace)
    image.to_blob
  end
  
  get "/:width/:height" do
    width = params[:width].to_i
    height = params[:height].to_i
    
    image = image_with_size(width, height)
    if image.class == String
      image
    else
      content_type 'image/jpeg'
      image.to_blob
    end
  end
  
  get "/g/:width/:height" do
    width = params[:width].to_i
    height = params[:height].to_i
    
    image = image_with_size(width, height)
    if image.class == String
      image
    else
      content_type 'image/jpeg'
      image = image.quantize(256, Magick::GRAYColorspace)
      image.to_blob
    end
  end
end
