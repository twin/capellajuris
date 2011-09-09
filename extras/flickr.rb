# get user by email
# get user's sets
# get all photos in a set
# get photo by ID
# get available photo sizes
#
# PHOTO: title url width height
require 'faraday_stack'
require 'securerandom'
require 'active_support/notifications'
require 'active_support/cache'

ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
  # $stderr.puts env[:body].inspect
end

module Flickr
  def self.client
    @client ||= begin
      client = FaradayStack::build Client,
        url: 'http://api.flickr.com/services/rest/',
        params: {
          format: 'json',
          nojsoncallback: '1',
          api_key: '1e7490875accc5b9c1ca91a2f27b5604'
        },
        request: {
          open_timeout: 2,
          timeout: 3
        }

      cache = ActiveSupport::Cache::FileStore.new File.join(ENV['TMPDIR'], 'juris-cache'),
          namespace: 'juris', expires_in: 60 * 60 * 24 * 7

      client.builder.insert_before FaradayStack::ResponseJSON, FaradayStack::Caching,
          cache, strip_params: %w[ api_key format nojsoncallback ]

      client.builder.insert_before FaradayStack::ResponseJSON, FaradayStack::Instrumentation
      client.builder.insert_before FaradayStack::ResponseJSON, StatusCheck
      client
    end
  end

  def self.photos_from_set(set_id)
    response = client.photos_from_set(set_id)
    response.body['photoset']['photo'].map {|hash| Photo.new(hash) }
  end

  def self.find_photo(photo_id)
    response = client.photo_sizes(photo_id)
    Photo.from_sizes response.body['sizes']['size']
  end

  class Photo
    SIZES = %w[ z m s t sq ]
    SIZE_NAMES = {
      large:     'z',
      medium:    'm',
      small:     's',
      thumbnail: 't',
      square:    'sq'
    }

    def self.from_sizes(sizes)
      new sizes.each_with_object({}) { |data, hash|
        label = data['label']
        label = :large if 'Medium 640' == label
        size = SIZE_NAMES[label.downcase.to_sym]
        hash["url_#{size}"] = data['source']
        hash["width_#{size}"] = data['width']
        hash["height_#{size}"] = data['height']
      }
    end

    def initialize(hash, size = nil)
      @hash = hash
      @size = size || detect_largest_size
    end

    def size
      SIZE_NAMES.key @size
    end

    def largest_size
      SIZE_NAMES.key detect_largest_size
    end

    SIZE_NAMES.each do |name, size|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          Photo.new(@hash, '#{size}')
        end
      RUBY
    end

    def width
      Integer(@hash["width_#{@size}"])
    end

    def height
      Integer(@hash["height_#{@size}"])
    end

    def url
      @hash["url_#{@size}"]
    end

    private

    def detect_largest_size
      SIZES.detect {|s| @hash["url_#{s}"] }
    end
  end

  class StatusCheck < Faraday::Response::Middleware
    def on_complete(env)
      unless env[:body]['stat'] == 'ok'
        raise env[:body]['message']
      end
    end
  end

  class Client < Faraday::Connection
    def get(method, params)
      super() do |req|
        req.params[:method] = method.to_s
        req.params.update params
      end
    end

    # {
    #   "user": {
    #     "id": "67131352@N04",
    #     "nsid": "67131352@N04",
    #     "username": {
    #       "_content": "Janko Marohnić"
    #     }
    #   },
    #   "stat": "ok"
    # }
    def find_person_by_email(email)
      get 'flickr.people.findByEmail', find_email: email
    end

    def photos_from_set(set_id)
      get 'flickr.photosets.getPhotos', photoset_id: set_id.to_s,
        media: 'photos', extras: 'url_sq,url_t,url_s,url_m,url_o,url_z'
    end

    def photo_sizes(photo_id)
      get 'flickr.photos.getSizes', photo_id: photo_id.to_s
    end

    def photo_info(photo_id)
      get 'flickr.photos.getInfo', photo_id: photo_id.to_s
    end
  end
end

__END__
photoset_id=72157627460265059

{"photoset"=>
  {"id"=>"72157627460265059",
   "primary"=>"6109216253",
   "owner"=>"67131352@N04",
   "ownername"=>"Janko Marohnić",
   "photo"=>
    [{"id"=>"6109212429",
      "secret"=>"8bbec8c624",
      "server"=>"6208",
      "farm"=>7,
      "title"=>"1",
      "isprimary"=>"0",
      "url_sq"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_s.jpg",
      "height_sq"=>75,
      "width_sq"=>75,
      "url_t"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_t.jpg",
      "height_t"=>"67",
      "width_t"=>"100",
      "url_s"=>
       "http://farm7.static.flickr.com/6208/6109212429_8bbec8c624_m.jpg",
      "height_s"=>"161",
      "width_s"=>"240",
      "url_m"=>"http://farm7.static.flickr.com/6208/6109212429_8bbec8c624.jpg",
      "height_m"=>"335",
      "width_m"=>"500"}
